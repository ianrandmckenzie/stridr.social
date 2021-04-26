class UpdateRecentPosts

  # def initialize(current_user, social_pages)
  #   @current_user = current_user
  #   @social_pages = social_pages
  # end
  #
  # def all
  #
  #   @social_pages.each do |page|if page.platform_name.downcase == "spotify"
  #       uri = URI.parse("https://api.spotify.com/v1/artists/" + page.platform_id + "/albums?limit=1")
  #       request = Net::HTTP::Get.new(uri)
  #       request["Authorization"] = "Bearer " + @current_user.spotify_token
  #
  #       req_options = {
  #         use_ssl: uri.scheme == "https",
  #       }
  #
  #       response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  #         http.request(request)
  #       end
  #
  #       write = JSON.parse response.body.gsub('=>', ':')
  #
  #       begin
  #         album = write['items'].first
  #         page.recent_post_url = album['external_urls']['spotify'] ? album['external_urls']['spotify'] : page.recent_post_url
  #         page.recent_post_message = album['name'] ? album['name'] : page.recent_post_message
  #         page.recent_post_image_url = album['images'][0]['url'] ? album['images'][0]['url'] : page.recent_post_image_url
  #         page.save
  #       rescue NoMethodError => e
  #         puts e
  #         puts write
  #         if write['error'] && write['error']['status'] == 401
  #           @current_user.unauthorized_accounts << "Spotify" unless @current_user.unauthorized_accounts.include? "Spotify"
  #           @current_user.save
  #         end
  #       end
  #     end
  #   end
  # end
end
