class AccountsController < ApplicationController
  before_action :authenticate_user!
  def customize
    if current_user.deviantart_loading ||
       current_user.facebook_loading ||
       current_user.instagram_loading ||
       current_user.pinterest_loading ||
       current_user.reddit_loading ||
       current_user.spotify_loading ||
       current_user.tumblr_loading ||
       current_user.twitch_loading ||
       current_user.twitter_loading ||
       current_user.youtube_loading
      respond_to do |format|
        format.html { }
        format.js { render 'table' }
      end
    end
  end
end
