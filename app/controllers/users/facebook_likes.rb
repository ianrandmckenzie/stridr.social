class Users::OmniauthCallbacksController::FacebookLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user

    # Koala::Facebook::AuthenticationError (type: OAuthException, code: 190,
    # error_subcode: 460, message: Error validating access token:
    # The session has been invalidated because the user changed their
    # password or Facebook has changed the session for security reasons.,
    # x-fb-trace-id: ARZs04pzYE7 [HTTP 400]):
    facebook_client = Koala::Facebook::API.new(current_user.facebook_token)

    begin
      # Get user likes
      feed = facebook_client.get_connections("me", "likes?fields=about,name,id,fan_count,website,current_location", {'limit' => 20})
      facebook_users = []
      while feed.next_page
        feed.each do |page|
          facebook_users << page
        end
        feed = feed.next_page
      end
      # Get user friends
      facebook_friends = facebook_client.get_connections("me", "friends?fields=id,friends", {'limit' => 100})
    rescue Koala::Facebook::AuthenticationError => e
      puts e
    end
    @friends = []

    facebook_friends.each do |friend|
      @friends << friend['id']
    end

    @new_pages = []

    facebook_users.each do |page|
      @new_pages << {
        :platform_id => page['id'],
        :page_name => page['name'],
        :page_image_url => facebook_client.get_picture(page['id'], {'type' => 'large'}),
        :follow_count => page['fan_count'],
        :platform_url => 'https://www.facebook.com/' + page['id'],
        :platform_name => 'Facebook',
        :description => page['about'],
        :location => page['current_location'],
        :website => page['website'],
      }
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    @friends.each do |friend|
      user = User.find_by(facebook_uid: friend)
      if user
        if !user.following.where(facebook_uid: current_user.facebook_uid).first
          user.following << current_user
          current_user.following << user
        end
      end
    end
  end
end
