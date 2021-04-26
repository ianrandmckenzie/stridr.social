class LoadContentFeedWorker
  require_relative './sync_youtube_worker'
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(filtered, current_user)
    current_user = User.find(current_user)
    if current_user.google_token && !current_user.youtube_filter
      SyncYoutubeWorker.perform_async(current_user.google_token)
    end

    find = FindRecentPosts.new(current_user)

    if filtered == nil then filtered = "" end

    if current_user.deviantart_token
      if filtered.exclude? "DeviantArt" then find.deviantart end
    end
    if current_user.facebook_token
      if filtered.exclude? "Facebook" then find.facebook end
    end
    if current_user.pinterest_token
      if filtered.exclude? "Pinterest" then find.pinterest end
    end
    if current_user.reddit_token
      if filtered.exclude? "Reddit" then find.reddit end
    end
    # Spotify not currently supported. Uncomment when it is.
    # if current_user.spotify_token
    #   if filtered.exclude? "Spotify" then find.spotify end
    # end
    # puts current_user.feed_status
    if current_user.tumblr_token
      if filtered.exclude? "Tumblr" then find.tumblr end
    end
    if current_user.twitch_token
      if filtered.exclude? "Twitch" then find.twitch end
    end
    if current_user.twitter_token
      if filtered.exclude? "Twitter" then find.twitter end
    end

    find.save

    current_user.feed_status = "Recent Posts Found!"
    current_user.last_recent_posts_sync = DateTime.now
    current_user.save
  end

end
