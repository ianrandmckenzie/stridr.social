class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'
  require_relative '../../workers/create_infographic_worker'
  require_relative 'deviantart_likes'
  require_relative 'facebook_likes'
  require_relative 'instagram_likes'
  require_relative 'pinterest_likes'
  require_relative 'reddit_likes'
  require_relative 'spotify_likes'
  require_relative 'tumblr_likes'
  require_relative 'twitch_likes'
  require_relative 'twitter_likes'
  require_relative 'youtube_likes'

  require 'net/http'
  require 'uri'

  skip_before_action

  def deviantart
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      token = auth.credentials.token

      current_user.deviantart_token = token
      current_user.deviantart_uid = auth.extra.raw_info.username
      current_user.deviantart_refresh = auth.credentials.refresh_token
      current_user.last_sync_date = DateTime.now
      current_user.deviantart_loading = true
      current_user.unauthorized_accounts.delete("DeviantArt")
      current_user.save

      da = DeviantartLikes.new(current_user.id)
      da.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "DeviantArt") if is_navigational_format?
    end
  end

  def facebook

    if !current_user
      auth = request.env["omniauth.auth"]
      not_user = User.where(email: auth.info.email).first
      real_user = User.find_by(provider: auth.provider, uid: auth.uid)
      authenticated_user = User.find_by(provider: auth.provider, uid: auth.uid, email: auth.info.email)
      if authenticated_user
        @user = User.from_omniauth(auth)
      elsif not_user && !not_user.uid
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via Stridr's system (Not Facebook/Google/Twitter/Twitch)."
        return
      elsif !real_user && not_user
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via " + not_user.provider.capitalize
        return
      else
        @user = User.from_omniauth(auth)
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?

        fb = FacebookLikes.new(current_user.id)
        fb.add
        MakeRecommendationsWorker.perform_async(current_user.id)
        CreateInfographicWorker.perform_async(current_user.id)
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env["omniauth.auth"]

      # immediately get 60 day auth token
      oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_ID"], ENV["FACEBOOK_SECRET"])
      new_access_info = oauth.exchange_access_token_info auth.credentials.token

      current_user.facebook_token = new_access_info["access_token"]
      current_user.facebook_uid = auth.uid
      auth.info.image = auth.info.image.sub! 'http://', 'https://'
      current_user.image = auth.info.image
      current_user.last_sync_date = DateTime.now
      current_user.facebook_loading = true
      current_user.unauthorized_accounts.delete("Facebook")
      current_user.save

      fb = FacebookLikes.new(current_user.id)
      fb.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    end

  end

  def google_oauth2

    if !current_user
      auth = request.env["omniauth.auth"]
      not_user = User.where(email: auth.info.email).first
      real_user = User.find_by(provider: auth.provider, uid: auth.uid)
      authenticated_user = User.find_by(provider: auth.provider, uid: auth.uid, email: auth.info.email)
      if authenticated_user
        @user = User.from_omniauth(auth)
      elsif not_user && !not_user.uid
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via Stridr's system (Not Facebook/Google/Twitter/Twitch)."
        return
      elsif !real_user && not_user
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via " + not_user.provider.capitalize
        return
      else
        @user = User.from_omniauth(auth)
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?

        yt = YoutubeLikes.new(current_user.id)
        yt.add
        MakeRecommendationsWorker.perform_async(current_user.id)
        CreateInfographicWorker.perform_async(current_user.id)
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env["omniauth.auth"]

      current_user.google_token = auth.credentials.token
      current_user.google_uid = auth.uid
      current_user.image = auth.info.image
      current_user.last_sync_date = DateTime.now
      current_user.youtube_loading = true
      current_user.unauthorized_accounts.delete("YouTube")
      current_user.save

      yt = YoutubeLikes.new(current_user.id)
      yt.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    end

  end

  def instagram
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      token = auth.credentials.token

      current_user.instagram_token = token
      current_user.instagram_uid = auth.uid
      current_user.last_sync_date = DateTime.now
      current_user.instagram_loading = true
      current_user.unauthorized_accounts.delete("Instagram")
      current_user.save

      ig = InstagramLikes.new(current_user.id)
      ig.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Instagram") if is_navigational_format?
    end
  end

  def pinterest
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      current_user.pinterest_token = auth.credentials.token
      current_user.pinterest_uid = auth.uid
      auth.info.url = auth.info.url.gsub('https://www.pinterest.com/','')
      auth.info.url = auth.info.url.gsub('/','')
      current_user.pinterest_username = auth.info.url
      current_user.last_sync_date = DateTime.now
      current_user.pinterest_loading = true
      current_user.unauthorized_accounts.delete("Pinterest")
      current_user.save

      pt = PinterestLikes.new(current_user.id)
      pt.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Pinterest") if is_navigational_format?
    end
  end

  def reddit
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      token = auth.credentials.token

      current_user.reddit_token = token
      current_user.reddit_uid = auth.uid
      current_user.reddit_username = auth.info.name
      current_user.last_sync_date = DateTime.now
      current_user.reddit_loading = true
      current_user.unauthorized_accounts.delete("Reddit")
      current_user.save

      rd = RedditLikes.new(current_user.id)
      rd.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Reddit") if is_navigational_format?
    end
  end

  def spotify
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      puts auth

      current_user.image = auth.info.image
      current_user.spotify_token = auth.credentials.token
      current_user.spotify_uid = auth.uid
      current_user.spotify_username = auth.info.nickname
      current_user.last_sync_date = DateTime.now
      current_user.spotify_loading = true
      current_user.unauthorized_accounts.delete("Spotify")
      current_user.save

      sy = SpotifyLikes.new(current_user.id)
      sy.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Spotify") if is_navigational_format?
    end
  end

  def tumblr
    if !current_user
      redirect_to new_user_registration_url
    else
      auth = request.env["omniauth.auth"]

      token = auth.credentials.token
      secret = auth.credentials.secret

      current_user.tumblr_token = token
      current_user.tumblr_secret = secret
      current_user.tumblr_uid = auth.info.name
      current_user.last_sync_date = DateTime.now
      current_user.tumblr_loading = true
      current_user.unauthorized_accounts.delete("Tumblr")
      current_user.save

      tum = TumblrLikes.new(current_user.id)
      tum.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Tumblr") if is_navigational_format?
    end
  end

  def twitch
    if !current_user
      auth = request.env["omniauth.auth"]
      not_user = User.where(email: auth.info.email).first
      real_user = User.find_by(provider: auth.provider, uid: auth.uid)
      authenticated_user = User.find_by(provider: auth.provider, uid: auth.uid, email: auth.info.email)
      if authenticated_user
        @user = User.from_omniauth(auth)
      elsif not_user && !not_user.uid
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via Stridr's system (Not Facebook/Google/Twitter/Twitch)."
        return
      elsif !real_user && not_user
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via " + not_user.provider.capitalize
        return
      else
        @user = User.from_omniauth(auth)
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Twitch") if is_navigational_format?

        tch = TwitchLikes.new(current_user.id)
        tch.add
        MakeRecommendationsWorker.perform_async(current_user.id)
        CreateInfographicWorker.perform_async(current_user.id)
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env["omniauth.auth"]

      puts auth

      current_user.twitch_token = auth.credentials.token
      current_user.twitch_username = auth.info.nickname
      current_user.twitch_uid = auth.uid
      if auth.info.image
        auth.info.image = auth.info.image.sub! 'http://', 'https://'
        current_user.image = auth.info.image
      end
      current_user.last_sync_date = DateTime.now
      current_user.twitch_loading = true
      current_user.unauthorized_accounts.delete("Twitch")
      current_user.save

      tch = TwitchLikes.new(current_user.id)
      tch.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Twitch") if is_navigational_format?
    end

  end

  def twitter
    if !current_user
      auth = request.env["omniauth.auth"]
      not_user = User.where(email: auth.info.email).first
      real_user = User.find_by(provider: auth.provider, uid: auth.uid)
      authenticated_user = User.find_by(provider: auth.provider, uid: auth.uid, email: auth.info.email)
      if authenticated_user
        @user = User.from_omniauth(auth)
      elsif not_user && !not_user.uid
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via Stridr's system (Not Facebook/Google/Twitter/Twitch)."
        return
      elsif !real_user && not_user
        redirect_to new_user_session_path
        flash[:notice] = "Email already taken. Please sign into your account via " + not_user.provider.capitalize
        return
      else
        @user = User.from_omniauth(auth)
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?

        tw = TwitterLikes.new(current_user.id)
        tw.add
        MakeRecommendationsWorker.perform_async(current_user.id)
        CreateInfographicWorker.perform_async(current_user.id)
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env["omniauth.auth"]

      current_user.twitter_username = auth.info.nickname
      current_user.twitter_token = auth.credentials.token
      current_user.twitter_secret = auth.credentials.secret
      current_user.twitter_uid = auth.uid
      auth.info.image = auth.info.image.sub! 'http://', 'https://'
      current_user.image = auth.info.image
      current_user.last_sync_date = DateTime.now
      current_user.twitter_loading = true
      current_user.unauthorized_accounts.delete("Twitter")
      current_user.save

      tw = TwitterLikes.new(current_user.id)
      tw.add
      MakeRecommendationsWorker.perform_async(current_user.id)
      CreateInfographicWorker.perform_async(current_user.id)
      @user = current_user

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
    end
  end

  def failure
    redirect_to root_path
  end

end
