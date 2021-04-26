class ApiUserRouteController < BaseApiController
  before_filter :find_user, only: [:show, :social_pages_list, :recommendations, :friends]
  before_filter :find_social_pages, only: [:social_pages_list]
  before_filter :find_recommendations, only: [:recommendations]
  before_filter :find_friends, only: [:friends]

  private

  def find_user
    @user = User.find(params[:id])
    render nothing: true, status: :not_found unless @user.present?
  end

  def find_social_pages
    @social_pages = @user.social_pages_list
    render nothing: true, status: :not_found unless @social_pages.present?
  end

  def find_recommendations
    @recommendations = @user.recommended_social_pages
    render nothing: true, status: :not_found unless @recommendations.present?
  end

  def find_friends
    @friends = @user.following.all
    render nothing: true, status: :not_found unless @friends.present?
  end
end
