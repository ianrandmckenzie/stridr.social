class Users::OmniauthCallbacksController::DeviantartLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'
  require_relative '../../workers/make_recommendations_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user
    uri = URI.parse("https://www.deviantart.com/api/v1/oauth2/user/friends/" + current_user.deviantart_uid + "?access_token=" + current_user.deviantart_token + "&limit=50")
    response = Net::HTTP.get_response(uri)
    write = JSON.parse response.body.gsub('=>', ':')
    puts write["error"]
    if write["error"]
      flash[:notice] = "DeviantArt says you're syncing your account too much! Try syncing later."
      redirect_to :controller => :accounts, :action => :customize and return
    end

    deviants = write["results"] || []
    ids = []

    deviants.each do |dev|
      ids << dev["user"]["username"]
    end
    while write["has_more"] do
      uri = URI.parse("https://www.deviantart.com/api/v1/oauth2/user/friends/" + current_user.deviantart_uid + "?access_token=" + current_user.deviantart_token + "&limit=50&offset=" + write["next_offset"].to_s)
      response = Net::HTTP.get_response(uri)
      write_more = JSON.parse response.body.gsub('=>', ':')
      if write["error"]
        flash[:notice] = "DeviantArt says you're syncing your account too much! Try syncing later."
        redirect_to :controller => :accounts, :action => :customize and return
      end
      deviants = write_more["results"]

      deviants.each do |dev|
        ids << dev["user"]["username"]
      end
      write = write_more
    end
    deviantart_users = []
    deviantart_lowres = []

    ids.each do |id|
      uri = URI.parse("https://www.deviantart.com/api/v1/oauth2/user/profile/" + id + "?access_token=" + current_user.deviantart_token)
      response = Net::HTTP.get_response(uri)
      write = JSON.parse response.body.gsub('=>', ':')
      if write["profile_pic"]
        deviantart_users << write
      else
        deviantart_lowres << write
      end
    end

    @new_pages = []
    @friends = []

    deviantart_lowres.each do |profile|
      profile["user"]["usericon"] = profile["user"]["usericon"].sub! 'http://', 'https://'
      @friends << profile["user"]["username"]
      @new_pages << {
        :page_name => profile["user"]["username"],
        :follow_count => profile["stats"]["profile_pageviews"].to_s,
        :description => profile["bio"],
        # :page_image_url => profile["profile_pic"]["content"]["src"],
        :page_image_url => profile["user"]["usericon"],
        :platform_id => profile["user"]["userid"],
        :platform_url => profile["profile_url"],
        :platform_name => "DeviantArt",
        :content_count => profile["stats"]["user_deviations"],
        :website => profile["website"],
        :banner_image_url => profile["cover_photo"],
        :location => profile["country"]
      }
    end

    deviantart_users.each do |profile|
      profile["user"]["usericon"] = profile["user"]["usericon"].sub! 'http://', 'https://'
      @friends << profile["user"]["username"]
      @new_pages << {
        :page_name => profile["user"]["username"],
        :follow_count => profile["stats"]["profile_pageviews"].to_s,
        :description => profile["bio"],
        :page_image_url => profile["profile_pic"]["content"]["src"],
        # :page_image_url => profile["user"]["usericon"],
        :platform_id => profile["user"]["userid"],
        :platform_url => profile["profile_url"],
        :platform_name => "DeviantArt",
        :content_count => profile["stats"]["user_deviations"],
        :website => profile["website"],
        :banner_image_url => profile["cover_photo"],
        :location => profile["country"]
      }
    end

    @friends.each do |friend|
      user = User.find_by(deviantart_uid: friend)
      if user
        if !current_user.following.where(deviantart_uid: user.deviantart_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.deviantart_uid)
          if !user.following.where(deviantart_uid: current_user.deviantart_uid).first
            user.following << current_user
          end
        end
      end
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    current_user.save
  end
end
