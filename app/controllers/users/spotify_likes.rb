class Users::OmniauthCallbacksController::SpotifyLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  def add
    current_user = @user

    uri = URI.parse("https://api.spotify.com/v1/me/following?type=artist")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer " + current_user.spotify_token

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    write = JSON.parse response.body.gsub('=>', ':')

    spotties = []
    while write["artists"]["cursors"]["after"]
      write["artists"]["items"].each do |spot|
        spotties << spot
      end

      uri = URI.parse("https://api.spotify.com/v1/me/following?type=artist&after=" + write["artists"]["cursors"]["after"])
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer " + current_user.spotify_token

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      write = JSON.parse response.body.gsub('=>', ':')
    end

    write["artists"]["items"].each do |spot|
      spotties << spot
    end

    @new_pages = []

    spotties.each do |profile|
      begin
        if profile["type"] == "artist"
          genres = profile["genres"]
          genres = genres.map { |s| "'#{s}'" }.join(' ')
          @new_pages << {
            :page_name => profile["name"],
            :follow_count => profile["followers"]["total"],
            :description => genres,
            :page_image_url => profile["images"][1]["url"],
            :platform_id => profile["id"],
            :platform_url => profile["external_urls"]["spotify"],
            :platform_name => "Spotify"
          }
        end
      rescue NoMethodError => e
        puts e
        puts profile
        next
      end
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)
  end
end
