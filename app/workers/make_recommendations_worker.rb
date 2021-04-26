class MakeRecommendationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(current_user)
    eng_tagger = EngTagger.new
    current_user = User.find(current_user)
    # This is what I call performing brain surgery with a rusty spoon.
    # Machine learning? Nueral nets? Fuck that, nested iterations!
    tagged_words = []
    bad_words = current_user.least_favorite_words || ""
    tagged_words << eng_tagger.add_tags(current_user.favorite_words)
    # Nouns and other
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
    words_hash = []
    # tagged_words.each do |tagged_word|
    #   if tagged_word
    #     # nouns
    #     eng_tagger.get_proper_nouns(tagged_word).select do |key, value|
    #       if value > 0
    #         nnp[key] = "NNP"
    #       end
    #     end
    #     words_hash << nnp
    #     eng_tagger.get_nouns(tagged_word).select do |key, value|
    #       if value > 0
    #         nn[key] = "NN"
    #       end
    #     end
    #     words_hash << nn
    #   # adverbs
    #     eng_tagger.get_adverbs(tagged_word).select do |key, value|
    #       if value > 0
    #         av[key] = "AV"
    #       end
    #     end
    #     words_hash << av
    #   # adjectives
    #     eng_tagger.get_adjectives(tagged_word).select do |key, value|
    #       if value > 0
    #         jj[key] = "JJ"
    #       end
    #     end
    #     words_hash << jj
    #     eng_tagger.get_comparative_adjectives(tagged_word).select do |key, value|
    #       if value > 0
    #         jjr[key] = "JJR"
    #       end
    #     end
    #     words_hash << jjr
    #     eng_tagger.get_superlative_adjectives(tagged_word).select do |key, value|
    #       if value > 0
    #         jjs[key] = "JJS"
    #       end
    #     end
    #     words_hash << jjs
    #   # verbs
    #     eng_tagger.get_infinitive_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vb[key] = "VB"
    #       end
    #     end
    #     words_hash << vb
    #     eng_tagger.get_past_tense_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vbd[key] = "VBD"
    #       end
    #     end
    #     words_hash << vbd
    #     eng_tagger.get_gerund_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vbg[key] = "VBG"
    #       end
    #     end
    #     words_hash << vbg
    #     eng_tagger.get_passive_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vbn[key] = "VBN"
    #       end
    #     end
    #     words_hash << vbn
    #     eng_tagger.get_base_present_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vbp[key] = "VBP"
    #       end
    #     end
    #     words_hash << vbp
    #     eng_tagger.get_present_verbs(tagged_word).select do |key, value|
    #       if value > 0
    #         vbz[key] = "VBZ"
    #       end
    #     end
    #     words_hash << vbz
    #   end
    # end


    social_pages = current_user.social_pages_list
    sample_feed = []

    results = {}

    social_pages.each do |page|
      page.categories.each do |category|
        if !results[category.word]
          results[category.word] = 1
        else
          results[category.word] += 1
        end
      end
    end

    top_picks = results.select{|key, hash| hash > current_user.min_recommendation && hash < current_user.max_recommendation }

    top_picks.keys.each do |pick|
      if bad_words.include? pick
        next
      end
      sample_feed << SocialPage.all.includes(:categories).where("categories.word" => pick).all
    end

    favorite_picks = current_user.categories.all

    favorite_picks.each do |pick|
      if bad_words.include? pick.word
        next
      end
      sample_feed << SocialPage.all.includes(:categories).where("categories.word" => pick.word).all
    end


    # Extract words from string: split(/\W+/)
    bad_words = bad_words.split(/\W+/)
    bad_words.each do |bad|
      sp = SocialPage.all.includes(:categories).where("categories.word" => bad).all

      sp.each do |page|
        current_user.recommended_social_pages.delete(page)
      end
    end

    if sample_feed[0]
      if sample_feed[0][0]
        sample_feed = sample_feed.flatten(1)
      end
    end

    social_pages.each do |page|
      sample_feed.delete(page)
    end


    page_ids = []
    sample_feed.each do |page|
      page_ids << { social_page_id: page.id, user_id: current_user.id }
    end
    begin
      current_user.recommendations.first_or_create!(page_ids)
    rescue PG::UniqueViolation => error
      puts error
    end
  end
end
