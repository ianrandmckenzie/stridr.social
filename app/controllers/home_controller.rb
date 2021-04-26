class HomeController < ApplicationController
  require_relative 'users/omniauth_callbacks_controller'

  def index
    if current_user && !current_user.twitter_uid && !current_user.pinterest_uid && !current_user.tumblr_uid && !current_user.facebook_uid && !current_user.google_uid && !current_user.instagram_uid && !current_user.deviantart_uid && !current_user.twitch_uid && !current_user.spotify_uid
      @unsynced = true
    end

    @home = true
    @filter = true
    if !current_user
      @not_logged_in = true
    end

    if !current_user || @unsynced
      @sample_feed = []
      @social_pages = []
      @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'Facebook').limit(7).sample(7)
      @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'YouTube').limit(7).sample(7)
      @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 1000000, 'Twitter').limit(7).sample(7)
      @social_pages << SocialPage.where('platform_name = ?', 'Tumblr').limit(7).sample(7)
      @social_pages << SocialPage.where('follow_count > ? AND platform_name = ?', 5000, 'Pinterest').limit(7).sample(7)

      @social_pages.each do |pages|
        if pages[0] != nil
          pages.each do |page|
            @sample_feed << page
            @sample_feed = Kaminari.paginate_array(@sample_feed.sample(@sample_feed.count)).page(params[:page]).per(15)
          end
        end
      end
    else
      check_unauthorized
      if !current_user.last_sync_date || current_user.last_sync_date < 14.days.ago && !@unsynced
        flash.now[:notice] = "Hey, it's been a while! You might want to <strong>#{view_context.link_to('sync your social accounts', accounts_customize_path)}</strong> so we can give you the best suggestions!".html_safe
      end
      if current_user.recommended_social_pages

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

        @sample_feed = Kaminari.paginate_array(current_user.recommended_social_pages.where.not(platform_name: @filtered).reverse).page(params[:page]).per(15)
        MakeRecommendationsWorker.perform_async(current_user.id)
      else
        @loading = true
      end
    end

    if params[:search].present?
      @search = true
      social_pages = []
      search = params[:search].split(/\W+/)
      search.each do |word|
        social_pages << SocialPage.all.includes(:categories).where("categories.word" => word).all
      end
      @sample_feed = social_pages.flatten(1)
      @sample_feed = Kaminari.paginate_array(@sample_feed).page(params[:page]).per(15)
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render(:partial => 'social_pages', :object => @sample_feed)
        end
      end
      format.js
    end
  end
end
