class FindRecentPosts

  def initialize(current_user)

    @current_user = current_user
    @social_pages = @current_user.social_pages_list
    @updated_pages = {}

    @deviants = []
    @faces = []
    @pins = []
    @subreddits = []
    @spots = []
    @tumbles = []
    @twitchers = []
    @tweeters = []

    @social_pages.each do |page|
      case page.platform_name
      when "DeviantArt"
        @deviants << page
      when "Facebook"
        @faces << page
      when "Pinterest"
        if page.board_creator
          @pins << page
        end
      when "Reddit"
        @subreddits << page
      when "Spotify"
        @spots << page
      when "Tumblr"
        @tumbles << page
      when "Twitch"
        @twitchers << page
      when "Twitter"
        @tweeters << page
      end
    end
  end

  def deviantart
    @current_user.feed_status = "Loading DeviantArt Feed"
    @current_user.save

    total = @deviants.count
    percent = 0.0

    @deviants.each_with_index do |page, index|
      if @current_user.deviantart_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading DeviantArt Feed (" + percent.to_s + "%)"
        @current_user.save
      end

      uri = URI.parse("https://www.deviantart.com/api/v1/oauth2/gallery/?username=" + page.page_name.to_s + "&access_token=" + @current_user.deviantart_token.to_s + "&limit=1")
      response = Net::HTTP.get_response(uri)
      write = JSON.parse response.body.gsub('=>', ':')

      begin
        post = write["results"].first
        if page.recent_post_date != post['published_time']
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: post['published_time'] ? post['published_time'] : page.recent_post_date,
            recent_post_url: post['url'] ? post['url'] : page.recent_post_url,
            recent_post_image_url: post['preview']['src'] ? post['preview']['src'] : page.recent_post_image_url,
            recent_post_message: post['title'] ? post['title'] : page.recent_post_message
          }
        end
      rescue NoMethodError => e
        puts e
        puts write
        if write['error'] && (write['error'] == "invalid_token" || write['error'] == "invalid_request") || write['error'] && write['error'] == "unauthorized_client"
          @current_user.unauthorized_accounts << "DeviantArt" unless @current_user.unauthorized_accounts.include? "DeviantArt"
          @current_user.save
        end
      end
    end
  end

  def facebook

    @current_user.feed_status = "Loading Facebook Feed"
    @current_user.save

    facebook_client = Koala::Facebook::API.new(@current_user.facebook_token)

    total = @faces.count
    percent = 0.0

    @faces.each_with_index do |page, index|
      if @current_user.facebook_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Facebook Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      begin
        feed = facebook_client.get_connections(page.platform_id, "feed?fields=id,permalink_url,message,full_picture,created_time", {'limit' => 1})
        if feed[0] && page.recent_post_date != feed[0]['created_time'].to_time.to_i
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: feed.first['created_time'].to_time.to_i,
            recent_post_url: feed.first['permalink_url'],
            recent_post_image_url: feed.first['full_picture'].blank? ? nil : feed.first['full_picture'],
            recent_post_message: feed.first['message']
          }
        end
      rescue Koala::Facebook::AuthenticationError => e
        puts e
        @current_user.unauthorized_accounts << "Facebook" unless @current_user.unauthorized_accounts.include? "Facebook"
        @current_user.save
      end
    end
  end

  def pinterest

    @current_user.feed_status = "Loading Pinterest Feed"
    @current_user.save

    total = @pins.count
    percent = 0.0

    @pins.each_with_index do |page, index|
      if @current_user.pinterest_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Pinterest Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      board = page.platform_url.gsub('https://www.pinterest.com/', '')
      uri = URI.parse("https://api.pinterest.com/v1/boards/" + board + "pins/?access_token=" + @current_user.pinterest_token + "&fields=id%2Clink%2Cnote%2Curl%2Cimage")
      response = Net::HTTP.get_response(uri)
      write = JSON.parse response.body.gsub('=>', ':')

      begin
        pin = write['data'].first

        if page.recent_post_date != pin["created_at"].to_time.to_i
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: pin["created_at"].to_time.to_i,
            recent_post_url: pin['link'],
            recent_post_image_url: pin['image']['original']['url'],
            recent_post_message: pin['note'],
          }
        end
      rescue NoMethodError => e
        puts e
        puts write
        if write['code'] && write['code'] == 3
          @current_user.unauthorized_accounts << "Pinterest" unless @current_user.unauthorized_accounts.include? "Pinterest"
          @current_user.save
        end
      end
    end
  end

  def reddit

    @current_user.feed_status = "Loading Reddit Feed"
    @current_user.save

    total = @subreddits.count
    percent = 0.0

    @subreddits.each_with_index do |page, index|
      if @current_user.reddit_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Reddit Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      url = page.platform_url.gsub("https://www", "https://oauth")
      uri = URI.parse(url + "new.json?sort=new")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "bearer " + @current_user.reddit_token
      request["User-Agent"] = "StridrClient/v1.05 by stridrsocial"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      write = JSON.parse response.body.gsub('=>', ':')

      begin
        post = write['data']['children'][0]['data']
        recent_post_url = post['url'] ? post['url'] : page.recent_post_url
        if post['preview'] && post['preview']['images'] && post['preview']['images'][0]['source']
          recent_post_image_url = post['preview']['images'][0]['source']['url'] ? post['preview']['images'][0]['source']['url'] : page.recent_post_image_url
        end
        if post['selftext'] == "" || post['selftext'] == nil
          recent_post_message = post['title'] ? post['title'] : page.recent_post_message
        else
          recent_post_message = post['selftext'] ? post['selftext'] : page.recent_post_message
        end
        if page.recent_post_date != post['created'].to_i
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: post['created'] ? post['created'].to_i : page.recent_post_date,
            recent_post_url: recent_post_url,
            recent_post_image_url: recent_post_image_url,
            recent_post_message: recent_post_message,
          }
        end
      rescue NoMethodError => e
        puts e
        puts write
        if write['error'] && write['error'] == 401
          @current_user.unauthorized_accounts << "Reddit" unless @current_user.unauthorized_accounts.include? "Reddit"
          @current_user.save
        end
      end
    end
  end

  def spotify
    @current_user.feed_status = "Loading Spotify Feed"
    @current_user.save
    # Albums endpoint for Spotify do not have a created_at time
    # Keep on eye on this github issue to see if they have changed this:
    # https://github.com/spotify/web-api/issues/359
  end

  def tumblr

    @current_user.feed_status = "Loading Tumblr Feed"
    @current_user.save

    total = @tumbles.count
    percent = 0.0

    @tumbles.each_with_index do |page, index|
      if @current_user.tumblr_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Tumblr Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      tumblr_client = Tumblr::Client.new({
        :consumer_key => ENV['TUMBLR_ID'],
        :consumer_secret => ENV['TUMBLR_SECRET'],
        :oauth_token => @current_user.tumblr_token,
        :oauth_token_secret => @current_user.tumblr_secret
      })

      tumblr_user = tumblr_client.posts page.platform_id + '.tumblr.com', :type => 'photo', :limit => 1

      begin
        recent_post = tumblr_user['posts'][0]
        tumblr_user = tumblr_user['blog']
        tumblr_user_image = tumblr_client.avatar page.platform_id + '.tumblr.com', 512

        if recent_post
          if page.recent_post_date != recent_post['timestamp']
            @updated_pages[page.id] = {
              id: page.id,
              recent_post_date: recent_post['timestamp'],
              recent_post_url: recent_post["post_url"],
              recent_post_image_url: recent_post['photos'][0]['original_size']['url'],
              recent_post_message: recent_post['caption'],
            }
          end
        end
      rescue NoMethodError => e
        puts e
      end
    end
  end

  def twitch
    @current_user.feed_status = "Loading Twitch Feed"
    @current_user.save

    total = @twitchers.count
    percent = 0.0

    @twitchers.each_with_index do |page, index|
      if @current_user.twitch_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Twitch Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      uri = URI.parse("https://api.twitch.tv/kraken/channels/" + page.platform_id + "/videos?limit=1")
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

      if write['_total'] && write['_total'] == 0
        @social_pages.delete(page)
        next
      end

      begin
        video = write['videos'].first

        if page.recent_post_date != video["published_at"].to_time.to_i
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: video["published_at"].to_time.to_i,
            recent_post_url: video['url'] ? video['url'] : page.recent_post_url,
            recent_post_video_url: video['_id'] ? "https://player.twitch.tv/?video=" + video['_id'] : page.recent_post_video_url,
            recent_post_message: video['title'] ? video['title'] : page.recent_post_message,
          }
        end
      rescue NoMethodError => e
        puts e
        puts write
      end
    end
  end

  def twitter
    @current_user.feed_status = "Loading Twitter Feed"
    @current_user.save

    total = @tweeters.count
    percent = 0.0

    @tweeters.each_with_index do |page, index|
      if @current_user.twitter_filter then next end
      percent = ((index.to_f / total.to_f) * 100.0).to_i
      if percent % 10 == 0
        @current_user.feed_status = "Loading Twitter Feed (" + percent.to_s + "%)"
        @current_user.save
      end
      # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
      def prepare_access_token(oauth_token, oauth_token_secret)
          consumer = OAuth::Consumer.new(ENV['TWITTER_ID'], ENV['TWITTER_SECRET'], { :site => "https://api.twitter.com", :scheme => :header })

          # now create the access token object from passed values
          token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
          access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

          return access_token
      end

      # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
      access_token = prepare_access_token(@current_user.twitter_token, @current_user.twitter_secret)

      # use the access token as an agent to get the home timeline
      response = access_token.request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=" + page.platform_id + "&count=1&trim_user=true&exclude_replies=true&include_rts=false&include_entities=true")

      write = JSON.parse response.body.gsub('=>', ':')
      begin
        if write.first && write.first['created_at'].to_time.to_i && page.recent_post_date != write.first['created_at'].to_time.to_i
          @updated_pages[page.id] = {
            id: page.id,
            recent_post_date: write.first['created_at'].to_time.to_i,
            recent_post_url: "https://www.twitter.com/statuses/" + write[0]['id'].to_s,
            recent_post_message: write[0]['id'],
          }
        end
      rescue NoMethodError => e
        puts e
        puts write
        if write.first && write['errors'] && write['errors'].first['code'] == 89
          @current_user.unauthorized_accounts << "Twitter" unless @current_user.unauthorized_accounts.include? "Twitter"
          @current_user.save
        end
      end
    end
  end

  def save
    if @updated_pages
      @updated_pages.delete(nil)
      begin
        SocialPage.update(@updated_pages.keys, @updated_pages.values)
      rescue PG::UniqueViolation => error
        puts error
      end
    end
  end
end
