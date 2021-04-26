class ApiSocialPageRouteController < BaseApiController
  before_filter :find_social_page, only: [:show, :suggestions]
  before_filter :find_suggestions, only: [:suggestions]
  before_filter :find_default, only: [:default]
  before_filter :find_search_results, only: [:search]

  private

  def find_social_page
    @social_page = SocialPage.find(params[:id])
    # To only show page_name and id:
    # @social_page = SocialPage.select('page_name', 'id').find(params[:id])
    render nothing: true, status: :not_found unless @social_page.present?
  end

  def find_suggestions
    @suggestions = @social_page.following.all

    render nothing: true, status: :not_found unless @suggestions.present?
  end

  def find_default
    @social_pages = []
    @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'Facebook').limit(7).sample(7)
    @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'YouTube').limit(7).sample(7)
    @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'Twitter').limit(7).sample(7)
    @social_pages << SocialPage.where('platform_name = ?', 'Tumblr').limit(7).sample(7)
    @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 5000, 'Pinterest').limit(7).sample(7)

    render nothing: true, status: :not_found unless @social_pages.present?
  end

  def find_search_results
    if params[:search].present?
      social_pages = []
      search = params[:search].split(/\W+/)
      search.each do |word|
        social_pages << SocialPage.all.includes(:categories).where("categories.word" => word).all
      end
      @search_results = social_pages.flatten(1)
      # @search_results = Kaminari.paginate_array(@search_results).page(params[:page]).per(15)
    end

    render nothing: true, status: :not_found unless @search_results.present?
  end
end
