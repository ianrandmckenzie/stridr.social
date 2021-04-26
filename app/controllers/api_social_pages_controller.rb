class ApiSocialPagesController < ApiSocialPageRouteController

  def index
    render json: SocialPage.all.limit(25).to_json(methods: [:stridr_followers, :thumb_avatar_url, :medium_avatar_url])
  end

  def show
    render json: @social_page.to_json(methods: [:stridr_followers, :thumb_avatar_url, :medium_avatar_url])
    # For only page name:
    # render json: @social_page, only: [:page_name]
  end

  def suggestions
    render json: @suggestions.to_json(methods: [:stridr_followers, :thumb_avatar_url, :medium_avatar_url])
  end

  def default
    render json: @social_pages.to_json(methods: [:stridr_followers, :thumb_avatar_url, :medium_avatar_url])
  end

  def search
    render json: @search_results.to_json(methods: [:stridr_followers, :thumb_avatar_url, :medium_avatar_url])
  end
end
