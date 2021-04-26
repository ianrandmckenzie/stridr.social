class Users::OmniauthCallbacksController::InstagramLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user
    uri = URI.parse("https://api.instagram.com/v1/users/self/follows?access_token=" + current_user.instagram_token)
    response = Net::HTTP.get_response(uri)
    write = JSON.parse response.body.gsub('=>', ':')

    grammers = write["data"]
    ids = []
    grammers.each do |gram|
      ids << gram["id"]
    end
    instagram_users = []

    ids.each do |id|
      uri = URI.parse("https://api.instagram.com/v1/users/" + id + "/?access_token=" + current_user.instagram_token)
      response = Net::HTTP.get_response(uri)
      write = JSON.parse response.body.gsub('=>', ':')
      instagram_users << write["data"]
    end

    @new_pages = []
    @friends = []

    instagram_users.each do |profile|
      @friends << profile["id"]
      @new_pages << {
        :page_name => profile["username"],
        :follow_count => profile["counts"]["followed_by"],
        :description => profile["bio"],
        :page_image_url => profile["profile_picture"],
        :platform_id => profile["id"],
        :platform_url => "https://www.instagram.com/" + profile["username"],
        :platform_name => "Instagram",
        :content_count => profile["counts"]["media"],
        :website => profile["website"],
      }
    end

    @friends.each do |friend|
      user = User.find_by(instagram_uid: friend)
      if user
        if !current_user.following.where(instagram_uid: user.instagram_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.instagram_uid)
          if !user.following.where(instagram_uid: current_user.instagram_uid).first
            user.following << current_user
          end
        end
      end
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    current_user.save
  end
end
