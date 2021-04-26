class SyncYoutubeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(google_token)
    Yt.configure do |config|
      config.log_level = :debug
    end
    Yt.configuration.client_id = ENV['GOOGLE_ID']
    Yt.configuration.client_secret = ENV['GOOGLE_SECRET']
    youtube_client = Yt::Account.new access_token: google_token

    begin
      youtubes = youtube_client.subscribed_channels

      youtubes.each do |channel|
        social_page = SocialPage.find_or_initialize_by(platform_id: channel.id)
        video =  channel.videos.first
        if video
          puts video.published_at
          social_page.recent_post_video_url = 'https://www.youtube.com/watch?v=' + video.instance_variable_get(:@id).to_s
          social_page.recent_post_date = video.published_at.to_time.to_i
          social_page.save
        end
      end
    rescue Yt::Errors::Unauthorized => e
      puts e
      current_user = User.find_by(google_token: google_token)
      current_user.unauthorized_accounts << "YouTube"
      current_user.save
    end
  end
end
