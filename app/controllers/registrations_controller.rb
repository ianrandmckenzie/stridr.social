class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def new
    super
  end

  def create
    super
  end

  def update
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
    end
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = @user.update_attributes(account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def destroy
    likes = current_user.find_liked_items
    likes.each do |social_page|
      social_page.unliked_by current_user
    end
    super
  end

  protected
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:email, :username, :password, :password_confirmation, :location, :description, :favorite_words, :least_favorite_words, :min_recommendation, :max_recommendation, :deviantart_filter, :facebook_filter, :pinterest_filter, :reddit_filter, :spotify_filter, :tumblr_filter, :twitch_filter, :twitter_filter, :youtube_filter) }
  end
end
