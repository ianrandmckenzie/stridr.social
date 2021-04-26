class SuggestionsDelegateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'
  require_relative 'make_suggestions_worker'

  def perform(new_pages, current_user)
    current_user = User.find(current_user)
    new_pages.each do |page_data|
      begin
        social_page = SocialPage.find_by(platform_id: page_data['platform_id'], platform_name: page_data['platform_name'])

        MakeSuggestionsWorker.perform_async(social_page.id)
      rescue NoMethodError => e
        puts e
        next
      end
    end

  end
end
