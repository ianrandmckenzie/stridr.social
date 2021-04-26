class Users::OmniauthCallbacksController::TumblrLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user
    tumblr_client = Tumblr::Client.new({
      :consumer_key => ENV['TUMBLR_ID'],
      :consumer_secret => ENV['TUMBLR_SECRET'],
      :oauth_token => current_user.tumblr_token,
      :oauth_token_secret => current_user.tumblr_secret
    })

    tumblr = tumblr_client.following

    # Tumblr following list has a max of 20, multiple calls need to be made to
    # get data for all pages. Separate calls must have an offset.
    blog_pages = []
    blog_pages << tumblr
    offset = 20

    if tumblr['total_blogs'] > 20
      ((tumblr['total_blogs'] / 20).ceil).times do
        blog_pages << tumblr_client.following(:offset => offset)
        offset = offset + 20
      end
    end

    blogs = []
    @new_pages = []
    @friends = []

    blog_pages.each do |tumblr_users|
      tumblr_users['blogs'].each do |page|
        blogs << page['name']
      end
    end

    blogs.each do |url|
      tumblr_user = tumblr_client.posts url + '.tumblr.com', :type => 'photo', :limit => 1
      begin
        recent_post = tumblr_user['posts'][0]
      rescue NoMethodError => e
        puts e
        puts "No Recent Post"
        next
      end
      tumblr_user = tumblr_user['blog']
      tumblr_user_image = 'https://api.tumblr.com/v2/blog/' + url + '.tumblr.com/avatar/512'
      # Prevents pornographic Tumblr pages from being written to database.
      if tumblr_user['is_nsfw'] == false

        if tumblr_user['title'] == nil || tumblr_user['title'] == ""
          tumblr_user['title'] = tumblr_user['name']
        end

        if tumblr_user['description'] == nil || tumblr_user['description'] == ""
          tumblr_user['description'] = "No description available."
        end

        if recent_post
          recent_post_message = recent_post['caption']
          recent_post_image_url = recent_post['photos'][0]['original_size']['url']
        end

        @friends << tumblr_user['name']

        @new_pages << {
          :platform_id => tumblr_user['name'],
          :page_name => tumblr_user['title'],
          :page_image_url => tumblr_user_image,
          :follow_count => "",
          :platform_url => tumblr_user['url'],
          :platform_name => 'Tumblr',
          :description => tumblr_user['description'],
          :recent_post_message => recent_post_message,
          :recent_post_image_url => recent_post_image_url,
        }
      end
    end

    puts @new_pages

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)


    @friends.each do |friend|
      user = User.find_by(tumblr_uid: friend)
      if user
        if !current_user.following.where(tumblr_uid: user.tumblr_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.tumblr_uid)
          if !user.following.where(tumblr_uid: current_user.tumblr_uid).first
            user.following << current_user
          end
        end
      end
    end
  end
end
