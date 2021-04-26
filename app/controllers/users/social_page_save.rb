class Users::OmniauthCallbacksController::SocialPageSave < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def social_save(new_pages, current_user)
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
      social_page.avatar = URI.parse(page_data['page_image_url'])
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
      social_page.save
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
      nn = [] # noun
      nnp = [] # proper noun
      # Adjectives
      jj = [] # adjective
      jjr = [] # adjective comparative
      jjs = [] # adjective superlative
      # Adverbs
      av = []
      # Verbs
      vb = [] # verb infinitive
      vbd = [] # verb past tense
      vbg = [] # verb gerund
      vbn = [] # verb past/passive participle
      vbp = [] # verb base present form
      vbz = [] # verb present 3SG -s form
      tagged_words.each do |tagged_word|
        if tagged_word
          # nouns
          eng_tagger.get_proper_nouns(tagged_word).select do |key, value|
            if value > 0
              nnp << key
            end
          end
          eng_tagger.get_nouns(tagged_word).select do |key, value|
            if value > 0
              nn << key
            end
          end
        # adverbs
          eng_tagger.get_adverbs(tagged_word).select do |key, value|
            if value > 0
              av << key
            end
          end
        # adjectives
          eng_tagger.get_adjectives(tagged_word).select do |key, value|
            if value > 0
              jj << key
            end
          end
          eng_tagger.get_comparative_adjectives(tagged_word).select do |key, value|
            if value > 0
              jjr << key
            end
          end
          eng_tagger.get_superlative_adjectives(tagged_word).select do |key, value|
            if value > 0
              jjs << key
            end
          end
        # verbs
          eng_tagger.get_infinitive_verbs(tagged_word).select do |key, value|
            if value > 0
              vb << key
            end
          end
          eng_tagger.get_past_tense_verbs(tagged_word).select do |key, value|
            if value > 0
              vbd << key
            end
          end
          eng_tagger.get_gerund_verbs(tagged_word).select do |key, value|
            if value > 0
              vbg << key
            end
          end
          eng_tagger.get_passive_verbs(tagged_word).select do |key, value|
            if value > 0
              vbn << key
            end
          end
          eng_tagger.get_base_present_verbs(tagged_word).select do |key, value|
            if value > 0
              vbp << key
            end
          end
          eng_tagger.get_present_verbs(tagged_word).select do |key, value|
            if value > 0
              vbz << key
            end
          end
        end
      end


      nn.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "NN"
        category.save
        social_page.categories << category
      end
      nnp.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "NNP"
        category.save
        social_page.categories << category
      end
      jj.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "JJ"
        category.save
        social_page.categories << category
      end
      jjr.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "JJR"
        category.save
        social_page.categories << category
      end
      jjs.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "JJS"
        category.save
        social_page.categories << category
      end
      av.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "AV"
        category.save
        social_page.categories << category
      end
      vb.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "VB"
        category.save
        social_page.categories << category
      end
      vbd.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "VBD"
        category.save
        social_page.categories << category
      end
      vbg.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "VBG"
        category.save
        social_page.categories << category
      end
      vbn.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "vbn"
        category.save
        social_page.categories << category
      end
      vbp.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "VBP"
        category.save
        social_page.categories << category
      end
      vbz.each do |word|
        category = Category.find_or_initialize_by(word: word)
        category.word = word
        category.word_type = "VBZ"
        category.save
        social_page.categories << category
      end

      social_page.liked_by current_user
      current_user.social_pages_list << social_page

      MakeSuggestionsWorker.perform_async(social_page.id)
    end

  end

end
