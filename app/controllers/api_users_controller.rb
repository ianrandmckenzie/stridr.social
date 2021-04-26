class ApiUsersController < ApiUserRouteController

  def show
    render json: @user, only: [:id, :username, :image, :description]
  end

  def social_pages_list
    render json: @social_pages
  end

  def recommendations
    render json: @recommendations
  end

  def friends
    render json: @friends, only: [:id, :username, :image, :description]
  end
end
