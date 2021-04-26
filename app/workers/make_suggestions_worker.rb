class MakeSuggestionsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(social_page)
    social_page = SocialPage.find(social_page)

    sample_feed = []

    results = {}

    categories = social_page.categories.all

    categories.each do |category|
      if !results[category.word]
        results[category.word] = 1
      else
        results[category.word] += 1
      end
    end

    top_picks = results.select{|key, hash| hash > 0 && hash < 8 }

    top_picks.keys.each do |pick|
      sample_feed << SocialPage.all.includes(:categories).where("categories.word" => pick).all
    end

    if sample_feed[0]
      if sample_feed[0][0]
        sample_feed = sample_feed.flatten(1)
      end
    end

    if sample_feed.include? social_page
      sample_feed.delete(social_page)
    end

    page_ids = []
    sample_feed.each do |page|
      page_ids << { follower_id: page.id }
    end
    begin
      social_page.passive_suggestions.first_or_create!(page_ids)
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => error
      puts error
    end
  end
end
