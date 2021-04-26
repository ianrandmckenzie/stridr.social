class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # saves the location before loading each page so we can return to the
  # right page. If we're on a devise page, we don't want to store that as the
  # place to return to (for example, we don't want to return to the sign in page
  # after signing in), which is what the :unless prevents
  before_action :store_current_location, :unless => :devise_controller?

  private
  # override the devise helper to store the current location so we can
  # redirect to it after loggin in or out. This override makes signing in
  # and signing up work automatically.
  def store_current_location
    store_location_for(:user, request.url)
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  # Redirect to account connection page after authenticating a social account
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || root_path
  end

  def check_unauthorized
    unauthorized_accounts = []
    if current_user.unauthorized_accounts.include? "DeviantArt"
      unauthorized_accounts << "DeviantArt"
    end
    if current_user.unauthorized_accounts.include? "Facebook"
      unauthorized_accounts << "Facebook"
    end
    if current_user.unauthorized_accounts.include? "Instagram"
      unauthorized_accounts << "Instagram"
    end
    if current_user.unauthorized_accounts.include? "Pinterest"
      unauthorized_accounts << "Pinterest"
    end
    if current_user.unauthorized_accounts.include? "Reddit"
      unauthorized_accounts << "Reddit"
    end
    if current_user.unauthorized_accounts.include? "Spotify"
      unauthorized_accounts << "Spotify"
    end
    if current_user.unauthorized_accounts.include? "Tumblr"
      unauthorized_accounts << "Tumblr"
    end
    if current_user.unauthorized_accounts.include? "Twitch"
      unauthorized_accounts << "Twitch"
    end
    if current_user.unauthorized_accounts.include? "Twitter"
      unauthorized_accounts << "Twitter"
    end
    if current_user.unauthorized_accounts.include? "YouTube"
      unauthorized_accounts << "YouTube"
    end

    flash[:notice] = "We ran into some trouble connecting your #{unauthorized_accounts.to_sentence} account(s). #{view_context.link_to('Please re-sync here.', accounts_customize_path)}" unless current_user.unauthorized_accounts == []
  end

end
