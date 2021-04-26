class SocialPageController < ApplicationController

  def index
    # Display only user's likes (alphabetically)
    @user = User.find(current_user.id)
    @social_pages = @user.social_pages_list.order(:page_name)
    # Display entire list alphabetically
    # @social_pages = SocialPage.all.order('lower(page_name) ASC')
    # Display entire list randomly
    # @social_pages = @social_pages.sample(@social_pages.count)
    @filter = true
  end

  def show
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
    @filter = true
    @social_page_show = true
    @social_page = SocialPage.find(params[:id])

    @social_pages = @social_page.following.all

    @social_pages = Kaminari.paginate_array(@social_pages.where.not(platform_name: @filtered)).page(params[:page]).per(15)

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
