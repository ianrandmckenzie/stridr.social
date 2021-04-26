class SocialPageSaveWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  require_relative 'suggestions_delegate_worker'

  def perform(new_pages, current_user)
    current_user = User.find(current_user)
    eng_tagger = EngTagger.new
    new_pages.each do |page_data|
      social_page = SocialPage.find_or_initialize_by(platform_id: page_data['platform_id'])
      page_data['page_description'] = ActionController::Base.helpers.strip_tags(page_data['page_description'])
      page_data['recent_post_message'] = ActionController::Base.helpers.strip_tags(page_data['recent_post_message'])
      social_page.page_name = page_data['page_name']
      social_page.follow_count = page_data['follow_count']
      social_page.description = page_data['description']
      social_page.page_image_url = page_data['page_image_url']
      # If there's a 404 response to the image or fails validation, the item
      # gets skipped to the next iteration. TODO: Handle these exceptions better
      begin
        social_page.avatar = URI.parse(page_data['page_image_url'])
      rescue URI::InvalidURIError, OpenURI::HTTPError => ex
        next
      end
      social_page.platform_id = page_data['platform_id']
      social_page.platform_url = page_data['platform_url']
      social_page.platform_name = page_data['platform_name']
      social_page.website = page_data['website']
      social_page.recent_post_message = page_data['recent_post_message']
      social_page.recent_post_url = page_data['recent_post_url']
      social_page.recent_post_image_url = page_data['recent_post_image_url']
      social_page.recent_post_video_url = page_data['recent_post_video_url']
      social_page.banner_image_url = page_data['banner_image_url']
      social_page.location = page_data['location']
      social_page.content_count = page_data['content_count']
      social_page.boards_count = page_data['boards_count']
      social_page.board_creator = page_data['board_creator']
      begin
        social_page.save!
      rescue ActiveRecord::RecordInvalid => invalid
        puts invalid.record.errors
        next
      end
      tagged_words = []
      if page_data['page_name']
        tagged_words << eng_tagger.add_tags(page_data['page_name'])
      end
      if page_data['description']
        tagged_words << eng_tagger.add_tags(page_data['description'])
      end
      if page_data['recent_post_message']
        tagged_words << eng_tagger.add_tags(page_data['recent_post_message'])
      end
      if page_data['location']
        tagged_words << eng_tagger.add_tags(page_data['location'])
      end
      if page_data['board_creator']
        tagged_words << eng_tagger.add_tags(page_data['board_creator'])
      end

      # Nouns and other(fw)
      nn = {} # noun
      nnp = {} # proper noun
      # Adjectives
      jj = {} # adjective
      jjr = {} # adjective comparative
      jjs = {} # adjective superlative
      # Adverbs
      av = {}
      # Verbs
      vb = {} # verb infinitive
      vbd = {} # verb past tense
      vbg = {} # verb gerund
      vbn = {} # verb past/passive participle
      vbp = {} # verb base present form
      vbz = {} # verb present 3SG -s form
      words_hash = []
      tagged_words.each do |tagged_word|
        if tagged_word
          # nouns
          eng_tagger.get_proper_nouns(tagged_word).select do |key, value|
            if value > 0
              nnp[key] = "NNP"
            end
          end
          words_hash << nnp
          eng_tagger.get_nouns(tagged_word).select do |key, value|
            if value > 0
              nn[key] = "NN"
            end
          end
          words_hash << nn
        # adverbs
          eng_tagger.get_adverbs(tagged_word).select do |key, value|
            if value > 0
              av[key] = "AV"
            end
          end
          words_hash << av
        # adjectives
          eng_tagger.get_adjectives(tagged_word).select do |key, value|
            if value > 0
              jj[key] = "JJ"
            end
          end
          words_hash << jj
          eng_tagger.get_comparative_adjectives(tagged_word).select do |key, value|
            if value > 0
              jjr[key] = "JJR"
            end
          end
          words_hash << jjr
          eng_tagger.get_superlative_adjectives(tagged_word).select do |key, value|
            if value > 0
              jjs[key] = "JJS"
            end
          end
          words_hash << jjs
        # verbs
          eng_tagger.get_infinitive_verbs(tagged_word).select do |key, value|
            if value > 0
              vb[key] = "VB"
            end
          end
          words_hash << vb
          eng_tagger.get_past_tense_verbs(tagged_word).select do |key, value|
            if value > 0
              vbd[key] = "VBD"
            end
          end
          words_hash << vbd
          eng_tagger.get_gerund_verbs(tagged_word).select do |key, value|
            if value > 0
              vbg[key] = "VBG"
            end
          end
          words_hash << vbg
          eng_tagger.get_passive_verbs(tagged_word).select do |key, value|
            if value > 0
              vbn[key] = "VBN"
            end
          end
          words_hash << vbn
          eng_tagger.get_base_present_verbs(tagged_word).select do |key, value|
            if value > 0
              vbp[key] = "VBP"
            end
          end
          words_hash << vbp
          eng_tagger.get_present_verbs(tagged_word).select do |key, value|
            if value > 0
              vbz[key] = "VBZ"
            end
          end
          words_hash << vbz
        end
      end

      words_hash = words_hash.reduce Hash.new, :merge
      new_words = words_hash.clone

      existing_words = Category.where(word: words_hash.keys).select("id, word")

      existing_words.each do |category|
        new_words.delete(category.word)
      end

      new_categories = []

      new_words.each do |key, value|
        new_categories << { word: key, word_type: value }
      end

      Category.create(new_categories)

      categories = Category.where(word: words_hash.keys).select("id")

      new_relevances = []

      categories.each do |category|
        new_relevances << { social_page_id: social_page.id, category_id: category.id }
      end

      # Model.where(attribute: [value1, value2])
      Relevance.create(new_relevances)


      social_page.liked_by current_user
      current_user.social_pages_list << social_page
    end

    if defined?(new_pages) && new_pages.first && new_pages.first['platform_name']
      platform = new_pages.first['platform_name'].downcase
    end

    case platform
    when "deviantart"
      current_user.deviantart_loading = false
      current_user.save
    when "facebook"
      current_user.facebook_loading = false
      current_user.save
    when "instagram"
      current_user.instagram_loading = false
      current_user.save
    when "pinterest"
      current_user.pinterest_loading = false
      current_user.save
    when "reddit"
      current_user.reddit_loading = false
      current_user.save
    when "spotify"
      current_user.spotify_loading = false
      current_user.save
    when "tumblr"
      current_user.tumblr_loading = false
      current_user.save
    when "twitch"
      current_user.twitch_loading = false
      current_user.save
    when "twitter"
      current_user.twitter_loading = false
      current_user.save
    when "youtube"
      current_user.youtube_loading = false
      current_user.save
    when nil
      current_user.deviantart_loading = false
      current_user.facebook_loading = false
      current_user.instagram_loading = false
      current_user.pinterest_loading = false
      current_user.reddit_loading = false
      current_user.spotify_loading = false
      current_user.tumblr_loading = false
      current_user.twitch_loading = false
      current_user.twitter_loading = false
      current_user.youtube_loading = false
      current_user.save
    end

    SuggestionsDelegateWorker.perform_async(new_pages, current_user.id)
    # This resets the last sync time so that the user feed can be populated with
    # newly followed/liked pages
    current_user.last_recent_posts_sync = 1.day.ago
    current_user.save
  end
end
