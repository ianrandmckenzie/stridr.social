class Users::OmniauthCallbacksController::PinterestLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user

    uri = URI.parse("https://api.pinterest.com/v1/me/following/users/?access_token=" + current_user.pinterest_token + "&fields=first_name%2Cid%2Clast_name%2Curl%2Cimage%2Ccounts%2Cbio%2Cusername")
    response = Net::HTTP.get_response(uri)
    write = JSON.parse response.body.gsub('=>', ':')
    pinterest_users = []
    pinterest_users << write['data']
    until !write["page"]["next"]
        uri = URI.parse(write["page"]["next"])
        response = Net::HTTP.get_response(uri)
        write = JSON.parse response.body.gsub('=>', ':')

        pinterest_users << write['data']
    end
    pinterest_users = pinterest_users.flatten(1)
    @new_pages = []
    @friends = []

    pinterest_users.each do |page|
      # Remove 60px dimensions
      page["image"]["60x60"]["url"].slice! "_60.jpg"
      @friends << page["id"]
      @new_pages << {
        :platform_id => page["id"],
        :page_name => page["first_name"] + " " + page["last_name"],
        # + '_444' adds 444px dimension
        :page_image_url => page["image"]["60x60"]["url"] + "_444.jpg",
        :follow_count => page["counts"]["followers"],
        :platform_url => page["url"],
        :platform_name => 'Pinterest',
        :description => page["bio"],
        :content_count => page["counts"]["pins"],
        :boards_count => page["counts"]["boards"],
      }
    end

    uri = URI.parse("https://api.pinterest.com/v1/me/following/boards/?access_token=" + current_user.pinterest_token + "&fields=id%2Cname%2Curl%2Cimage%2Ccounts%2Cdescription%2Ccreator%2Cprivacy")
    response = Net::HTTP.get_response(uri)
    write = JSON.parse response.body.gsub('=>', ':')
    pinterest_boards = []
    pinterest_boards << write['data']
    until !write["page"]["next"]
        uri = URI.parse(write["page"]["next"])
        response = Net::HTTP.get_response(uri)
        write = JSON.parse response.body.gsub('=>', ':')

        pinterest_boards << write['data']
    end
    pinterest_boards = pinterest_boards.flatten(1)

    pinterest_boards.each do |page|
      sp = SocialPage.find_by(platform_id: page["creator"]["id"])
      if sp
        page["image"]["60x60"]["url"] = sp.page_image_url
      end
      @new_pages << {
        :platform_id => page["id"],
        :page_name => page["name"],
        :page_image_url => page["image"]["60x60"]["url"],
        :follow_count => page["counts"]["followers"],
        :platform_url => page["url"],
        :platform_name => 'Pinterest',
        :description => page["bio"],
        :content_count => page["counts"]["pins"],
        # TODO: Loop through board creators to make social pages for these
        # creators if they don't already exist.
        :board_creator => page["creator"]["id"],
      }
    end
    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)


    @friends.each do |friend|
      user = User.find_by(pinterest_uid: friend)
      if user
        if !current_user.following.where(pinterest_uid: user.pinterest_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.pinterest_uid)
          if !user.following.where(pinterest_uid: current_user.pinterest_uid).first
            user.following << current_user
          end
        end
      end
    end
  end
end
