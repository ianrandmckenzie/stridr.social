class Users::OmniauthCallbacksController::TwitchLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user
    uri = URI.parse("https://api.twitch.tv/kraken/users/" + current_user.twitch_uid + "/follows/channels?limit=100")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.twitchtv.v5+json"
    request["Client-Id"] = ENV["TWITCH_ID"]

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    write = JSON.parse response.body.gsub('=>', ':')

    twitchies = []

    write["follows"].each do |page|
      twitchies << page
    end

    ((write["_total"].to_f / 100).ceil).times do |index|
      offset = (index + 1) * 100

      uri = URI.parse("https://api.twitch.tv/kraken/users/" + current_user.twitch_uid + "/follows/channels?limit=100&offset=" + offset.to_s)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.twitchtv.v5+json"
      request["Client-Id"] = ENV["TWITCH_ID"]

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      write = JSON.parse response.body.gsub('=>', ':')

      write["follows"].each do |page|
        twitchies << page
      end
    end


    @new_pages = []
    @friends = []

    twitchies.each do |profile|
      @friends << profile["channel"]["_id"]
      @new_pages << {
        :page_name => profile["channel"]["display_name"],
        :follow_count => profile["channel"]["followers"],
        :description => profile["channel"]["description"],
        :page_image_url => profile["channel"]["logo"],
        :platform_id => profile["channel"]["_id"],
        :platform_url => profile["channel"]["url"],
        :platform_name => "Twitch",
        :recent_post_message => profile["channel"]["status"],
        :recent_post_image_url => profile["channel"]["video_banner"],
        :banner_image_url => profile["channel"]["profile_banner"]
      }
    end

    @friends.each do |friend|
      user = User.find_by(twitch_uid: friend)
      if user
        if !current_user.following.where(twitch_uid: user.twitch_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.twitch_uid)
          if !user.following.where(twitch_uid: current_user.twitch_uid).first
            user.following << current_user
          end
        end
      end
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    current_user.save
  end
end
