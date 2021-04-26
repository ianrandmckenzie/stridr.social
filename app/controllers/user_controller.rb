class UserController < ApplicationController

  require_relative '../workers/load_content_feed_worker'
  require_relative './update_recent_posts'
  require_relative './find_recent_posts'

  before_action :authenticate_user!, :except => [:show, :feed]
  before_action :check_unauthorized, :except => [:show, :feed]

  def loading
    @filtered = []
    if current_user
      check_unauthorized
      if current_user.deviantart_filter
        @filtered << "DeviantArt"
      end
      if current_user.facebook_filter
        @filtered << "Facebook"
      end
      if current_user.instagram_filter
        @filtered << "Instagram"
      end
      if current_user.pinterest_filter
        @filtered << "Pinterest"
      end
      if current_user.reddit_filter
        @filtered << "Reddit"
      end
      if current_user.spotify_filter
        @filtered << "Spotify"
      end
      if current_user.tumblr_filter
        @filtered << "Tumblr"
      end
      if current_user.twitch_filter
        @filtered << "Twitch"
      end
      if current_user.twitter_filter
        @filtered << "Twitter"
      end
      if current_user.youtube_filter
        @filtered << "YouTube"
      end
    end
    LoadContentFeedWorker.perform_async(@filtered, current_user.id)
    redirect_to root_path
  end

  def show
    @user_show = true
    @user = User.find(params[:id])
    @social_pages = Kaminari.paginate_array(@user.social_pages_list.order(:page_name)).page(params[:page]).per(20)
    @filter = true
    @badges = 0

    if @user.deviantart_uid
      @badges = @badges + 1
    end
    if @user.facebook_uid
      @badges = @badges + 1
    end
    if @user.instagram_uid
      @badges = @badges + 1
    end
    if @user.pinterest_uid
      @badges = @badges + 1
    end
    if @user.reddit_uid
      @badges = @badges + 1
    end
    if @user.spotify_uid
      @badges = @badges + 1
    end
    if @user.tumblr_uid
      @badges = @badges + 1
    end
    if @user.twitch_uid
      @badges = @badges + 1
    end
    if @user.twitter_uid
      @badges = @badges + 1
    end
    if @user.google_uid
      @badges = @badges + 1
    end
    if @user.social_pages_list.count >= 50
      @badges = @badges + 1
    end
    if @user.social_pages_list.count >= 100
      @badges = @badges + 1
    end
    if @user.social_pages_list.count >= 250
      @badges = @badges + 1
    end
    if @user.social_pages_list.count >= 1000
      @badges = @badges + 1
    end
    if @user.following.all.count >= 10
      @badges = @badges + 1
    end
    if @user.following.all.count >= 50
      @badges = @badges + 1
    end
    if @user.following.all.count >= 100
      @badges = @badges + 1
    end
    if @user.id <= (User.all.count * 0.05).floor
      @badges = @badges + 1
    end

    @deviantart_count = 0
    @facebook_count = 0
    @instagram_count = 0
    @pinterest_count = 0
    @reddit_count = 0
    @spotify_count = 0
    @tumblr_count = 0
    @twitch_count = 0
    @twitter_count = 0
    @youtube_count = 0

    @user.find_liked_items.each do |p|
      begin
        case p.platform_name
        when "DeviantArt"
          @deviantart_count = @deviantart_count + 1
        when "Facebook"
          @facebook_count = @facebook_count + 1
        when "Instagram"
          @instagram_count = @instagram_count + 1
        when "Pinterest"
          @pinterest_count = @pinterest_count + 1
        when "Reddit"
          @reddit_count = @reddit_count + 1
        when "Spotify"
          @spotify_count = @spotify_count + 1
        when "Tumblr"
          @tumblr_count = @tumblr_count + 1
        when "Twitch"
          @twitch_count = @twitch_count + 1
        when "Twitter"
          @twitter_count = @twitter_count + 1
        when "YouTube"
          @youtube_count = @youtube_count + 1
        end
      rescue NoMethodError => e
        puts e
        next
      end
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render(:partial => 'social_pages', :object => @social_pages)
        end

      end
      format.js

      format.png do
        expires_in 24.hours, public: true
        kit = IMGKit.new render_to_string, width: 550, height: 850, "disable-smart-width": true
        send_data kit.to_png, type: "image/png", disposition: "inline"
      end
    end

    if current_user
      @user = User.find(params[:id])
      @user_pages = @user.social_pages_list.where.not(platform_name: @filtered)

      @my_pages = current_user.social_pages_list

      @matches = []
      @differences = []
      @matched = false

      @user_pages.each do |page|
        @my_pages.each do |mine|
          if page == mine
            @matches << mine
            @matched = true
          end
        end
        if !@matched
          @differences << page
        else
          @matched = false
        end
      end

      @matches_count = @matches.count
      @differences_count = @differences.count
    end
  end

  def feed

    if !current_user
      redirect_to home_index_url
    else
      @filtered = []
      if current_user
        check_unauthorized
        if current_user.deviantart_filter
          @filtered << "DeviantArt"
        end
        if current_user.facebook_filter
          @filtered << "Facebook"
        end
        if current_user.instagram_filter
          @filtered << "Instagram"
        end
        if current_user.pinterest_filter
          @filtered << "Pinterest"
        end
        if current_user.reddit_filter
          @filtered << "Reddit"
        end
        if current_user.spotify_filter
          @filtered << "Spotify"
        end
        if current_user.tumblr_filter
          @filtered << "Tumblr"
        end
        if current_user.twitch_filter
          @filtered << "Twitch"
        end
        if current_user.twitter_filter
          @filtered << "Twitter"
        end
        if current_user.youtube_filter
          @filtered << "YouTube"
        end
      end

      if current_user.last_recent_posts_sync < 1.hour.ago
        LoadContentFeedWorker.perform_async(@filtered, current_user.id)
      end

      @all_in_one_feed = true
      @user = current_user
      @filter = true
      if @filtered.include? "Pinterest"
        @social_pages = Kaminari.paginate_array(@user.social_pages_list.where.not(platform_name: @filtered, recent_post_date: [nil]).order(recent_post_date: :desc)).page(params[:page]).per(10)
      else
        # This query excludes Pinterest "users" and only shows "boards" because of
        # Pinterest's API restrictions
        @filtered << "Pinterest"
        @social_pages = Kaminari.paginate_array(@user.social_pages_list.where.not(board_creator: [nil]).or(@user.social_pages_list.where.not(platform_name: @filtered, recent_post_date: [nil])).order(recent_post_date: :desc)).page(params[:page]).per(10)
      end

      respond_to do |format|
        format.html do
          if request.xhr?
            render(:partial => 'social_pages', :object => @social_pages)
          end

        end
        format.js { render 'user/loading_card' }
      end
    end
  end

  def friends
    @social_pages = current_user.following.all
  end

  def match
    @filtered = []
    if current_user
      if current_user.deviantart_filter
        @filtered << "DeviantArt"
      end
      if current_user.facebook_filter
        @filtered << "Facebook"
      end
      if current_user.instagram_filter
        @filtered << "Instagram"
      end
      if current_user.pinterest_filter
        @filtered << "Pinterest"
      end
      if current_user.reddit_filter
        @filtered << "Reddit"
      end
      if current_user.spotify_filter
        @filtered << "Spotify"
      end
      if current_user.tumblr_filter
        @filtered << "Tumblr"
      end
      if current_user.twitch_filter
        @filtered << "Twitch"
      end
      if current_user.twitter_filter
        @filtered << "Twitter"
      end
      if current_user.youtube_filter
        @filtered << "YouTube"
      end
    end
    @filter = true
    @match = true
    @user = User.find(params[:id])
    @user_pages = @user.social_pages_list.where.not(platform_name: @filtered)

    @my_pages = current_user.social_pages_list

    @matches = []
    @differences = []
    @matched = false

    @user_pages.each do |page|
      @my_pages.each do |mine|
        if page == mine
          @matches << mine
          @matched = true
        end
      end
      if !@matched
        @differences << page
      else
        @matched = false
      end
    end

    @matches.sort! { |a,b| a.page_name.downcase <=> b.page_name.downcase }
    @social_pages = Kaminari.paginate_array(@matches).page(params[:page]).per(20)

    respond_to do |format|
      format.html do
        if request.xhr?
          render(:partial => 'social_pages', :object => @social_pages)
        end

      end
      format.js
    end
  end

  def difference
    @filtered = []
    if current_user
      if current_user.deviantart_filter
        @filtered << "DeviantArt"
      end
      if current_user.facebook_filter
        @filtered << "Facebook"
      end
        puts "Facebook is filtered"
      if current_user.instagram_filter
        @filtered << "Instagram"
      end
      if current_user.pinterest_filter
        @filtered << "Pinterest"
      end
      if current_user.reddit_filter
        @filtered << "Reddit"
      end
      if current_user.spotify_filter
        @filtered << "Spotify"
      end
      if current_user.tumblr_filter
        @filtered << "Tumblr"
      end
      if current_user.twitch_filter
        @filtered << "Twitch"
      end
      if current_user.twitter_filter
        @filtered << "Twitter"
      end
      if current_user.youtube_filter
        @filtered << "YouTube"
      end
    end
    @difference = true
    @filter = true
    @user = User.find(params[:id])
    @user_pages = @user.social_pages_list.where.not(platform_name: @filtered)

    @my_pages = current_user.social_pages_list

    @matches = []
    @differences = []
    @matched = false

    @user_pages.each do |page|
      @my_pages.each do |mine|
        if page == mine
          @matches << mine
          @matched = true
        end
      end
      if !@matched
        @differences << page
      else
        @matched = false
      end
    end

    @matches.sort! { |a,b| a.page_name.downcase <=> b.page_name.downcase }
    @social_pages = Kaminari.paginate_array(@differences).page(params[:page]).per(20)

    respond_to do |format|
      format.html do
        if request.xhr?
          render(:partial => 'social_pages', :object => @social_pages)
        end

      end
      format.js
    end
  end

end
