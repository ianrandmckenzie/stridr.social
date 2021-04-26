class Users::OmniauthCallbacksController::RedditLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user

    uri = URI.parse("https://oauth.reddit.com/subreddits/mine/subscriber?limit=25")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "bearer " + current_user.reddit_token
    request["User-Agent"] = "StridrClient/v1.05 by stridrsocial"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    write = JSON.parse response.body.gsub('=>', ':')
    le_fedoras = []

    while write["data"]["after"]

      new_page = write["data"]["after"]

      write["data"]["children"].each do |le_tip|
        le_fedoras << le_tip
      end

      uri = URI.parse("https://oauth.reddit.com/subreddits/mine/subscriber?limit=25&after=" + new_page)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "bearer " + current_user.reddit_token
      request["User-Agent"] = "StridrClient/v1.02 by stridrsocial"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      write = JSON.parse response.body.gsub('=>', ':')
    end

    write["data"]["children"].each do |le_tip|
      le_fedoras << le_tip
    end

    @new_pages = []
    @friends = []

    le_fedoras.each do |profile|
      profile = profile["data"]
      if profile["subreddit_type"] == "public" || profile["subreddit_type"] == nil
        le_tip = {
          :page_name => profile["title"].gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '').gsub("&amp;", "&").gsub("&gt;", ">").gsub("&lt;", "<"),
          :follow_count => profile["subscribers"],
          :page_image_url => profile["icon_img"],
          :platform_id => profile["id"],
          :platform_url => "https://www.reddit.com" + profile["url"],
          :platform_name => "Reddit"
        }
        # Header titles, if they exist, are more concise descriptions.
        # This is an attempt to limit verbose descriptions weighted down with
        # offputting language and rules.
        if profile["header_title"]
          le_tip[:description] = profile["header_title"].gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '').gsub("&amp;", "&").gsub("&gt;", ">").gsub("&lt;", "<")
        else
          le_tip[:description] = profile["description"].gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '').gsub("&amp;", "&").gsub("&gt;", ">").gsub("&lt;", "<")
        end

        if profile["icon_img"] != "" && profile["icon_img"]
          le_tip[:page_image_url] = profile["icon_img"]
        elsif profile["header_img"] != "" && profile["header_img"]
          le_tip[:page_image_url] = profile["header_img"]
        else
          le_tip[:page_image_url] = "https://www.stridr.social/reddit.png"
        end

        @new_pages << le_tip
      end
    end


    uri = URI.parse("https://oauth.reddit.com/api/v1/me/friends?limit=25")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "bearer " + current_user.reddit_token
    request["User-Agent"] = "StridrClient/v1.02 by stridrsocial"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    write = JSON.parse response.body.gsub('=>', ':')
    le_fedoras = []

    while write["data"]["after"]

      new_page = write["data"]["after"]

      write["data"]["children"].each do |le_tip|
        le_fedoras << le_tip
      end

      uri = URI.parse("https://oauth.reddit.com/api/v1/me/friends?limit=25&after=" + new_page)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "bearer " + current_user.reddit_token
      request["User-Agent"] = "StridrClient/v1.02 by stridrsocial"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      write = JSON.parse response.body.gsub('=>', ':')
    end

    write["data"]["children"].each do |le_tip|
      le_fedoras << le_tip
    end

    le_fedoras.each do |friend|
      friend["id"].slice! "t2_"
      @friends << friend["id"]
      puts friend
    end

    @friends.each do |friend|
      user = User.find_by(reddit_uid: friend)
      if user
        if !current_user.following.where(reddit_uid: user.reddit_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.reddit_uid)
          if !user.following.where(reddit_uid: current_user.reddit_uid).first
            user.following << current_user
          end
        end
      end
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)
  end
end
