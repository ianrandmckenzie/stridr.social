class Users::OmniauthCallbacksController::YoutubeLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user
    Yt.configure do |config|
      config.log_level = :debug
    end
    Yt.configuration.client_id = ENV['GOOGLE_ID']
    Yt.configuration.client_secret = ENV['GOOGLE_SECRET']
    youtube_client = Yt::Account.new access_token: current_user.google_token

    youtubes = youtube_client.subscribed_channels
    @new_pages = []

    youtubes.each do |channel|
      begin
        if !channel.unlisted? && channel.public? && channel.subscriber_count_visible?
          @new_pages << {
            :page_name => channel.title,
            :follow_count => channel.subscriber_count,
            :description => channel.description,
            :page_image_url => channel.thumbnail_url,
            :platform_id => channel.id,
            :platform_url => 'https://www.youtube.com/channel/' + channel.id,
            :platform_name => 'YouTube',
            :recent_post_video_url => 'https://www.youtube.com/watch?v=' + channel.videos.first.instance_variable_get(:@id).to_s, # Recent video
            :content_count => channel.video_count, # Amount of videos uploaded
          }
        end
      rescue Yt::Errors::NoItems => e
        puts e
        next
      end       
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    current_user.save

  end
end
