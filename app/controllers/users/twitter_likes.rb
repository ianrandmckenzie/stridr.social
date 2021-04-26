class Users::OmniauthCallbacksController::TwitterLikes < Devise::OmniauthCallbacksController
  require_relative '../../workers/social_page_save_worker'

  def initialize(user)
    @user = User.find(user)
  end

  # def percent_encode(string)
  #   OAuth::Helper::escape string
  # end
  #
  # def nonce
  #   rand(36 ** 32 - 1).to_s(36).rjust(32, "0")
  # end

  def add
    current_user = @user
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                                                                   #
    # This massive block of code represents me trying to create         #
    # Twitter authentication for signed requests. I never got it        #
    # working, and, as it turns out, the few lines of code below this   #
    # does exactly the same thing using the OAuth gem. Maybe this       #
    # code could be used later. I'm not to keen on deleting 10 hours    #
    # of coding and making Brittany annoyed at me for working too       #
    # much. See the link below for the instructions to writing this     #
    # code:                                                             #
    # Creating a signature:                                             #
    # https://dev.twitter.com/oauth/overview/creating-signatures        #
    # Authorizing requests:                                             #
    # https://dev.twitter.com/oauth/overview/authorizing-requests       #
    #                                                                   #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #
    # base_url = "https://api.twitter.com/1.1/friends/list.json"
    # http_method = "GET"
    #
    # # Paramaters
    # user_id = current_user.twitter_uid
    # cursor = "-1"
    # count = "200"
    # skip_status = "false"
    # include_user_entities = "true"
    # oauth_consumer_key = ENV["TWITTER_ID"]
    # oauth_nonce = nonce
    # oauth_signature_method = "HMAC-SHA1"
    # oauth_timestamp = Time.now.getutc.to_i
    # oauth_timestamp = oauth_timestamp.to_s
    # oauth_token = current_user.twitter_token
    # oauth_version = "1.0"
    #
    # # Signing key components
    # consumer_secret = ENV["TWITTER_SECRET"]
    # oauth_token_secret = current_user.twitter_secret
    #
    # # Create parameter string:
    # # KEYS MUST BE IN ALPHABETICAL ORDER
    # parameter_string = ""
    # parameter_string << percent_encode("count") + "=" + percent_encode(count) + "&"
    # parameter_string << percent_encode("cursor") + "=" + percent_encode(cursor) + "&"
    # parameter_string << percent_encode("include_user_entities") + "=" + percent_encode(include_user_entities) + "&"
    # parameter_string << percent_encode("oauth_consumer_key") + "=" + percent_encode(oauth_consumer_key) + "&"
    # parameter_string << percent_encode("oauth_nonce") + "=" + percent_encode(oauth_nonce) + "&"
    # parameter_string << percent_encode("oauth_signature_method") + "=" + percent_encode(oauth_signature_method) + "&"
    # parameter_string << percent_encode("oauth_timestamp") + "=" + percent_encode(oauth_timestamp) + "&"
    # parameter_string << percent_encode("oauth_token") + "=" + percent_encode(oauth_token) + "&"
    # parameter_string << percent_encode("oauth_version") + "=" + percent_encode(oauth_version) + "&"
    # parameter_string << percent_encode("skip_status") + "=" + percent_encode(skip_status) + "&"
    # parameter_string << percent_encode("user_id") + "=" + percent_encode(user_id) # Do not append "&" to last parameter
    #
    # # Create signature base string
    # signature_base_string = ""
    # signature_base_string << percent_encode(http_method) + "&"
    # signature_base_string << percent_encode(base_url) + "&"
    # signature_base_string << percent_encode(parameter_string) # Do not append "&" to last parameter
    #
    # # Create signing key
    # key = percent_encode(consumer_secret) + "&" + percent_encode(oauth_token_secret)
    #
    # # Generate signature:
    # # Use SHA1 algorithm
    # digest = OpenSSL::Digest.new('sha1')
    # data = percent_encode(signature_base_string)
    #
    # hmac = OpenSSL::HMAC::digest(digest, key, data)
    # signature = Base64.encode64(hmac)
    #
    # oauth_signature = signature
    #
    # # Create header string
    # authorization_header = 'Oauth '
    # authorization_header << 'oauth_consumer_key' + '=' + '"' + oauth_consumer_key + '"' + ','
    # authorization_header << 'oauth_nonce' + '=' + '"' + oauth_nonce + '"' + ','
    # authorization_header << 'oauth_signature' + '=' + '"' + percent_encode(oauth_signature) + '"' + ','
    # authorization_header << 'oauth_signature_method' + '=' + '"' + oauth_signature_method + '"' + ','
    # authorization_header << 'oauth_timestamp' + '=' + '"' + oauth_timestamp + '"' + ','
    # authorization_header << 'oauth_token' + '=' + '"' + oauth_token + '"' + ','
    # authorization_header << 'oauth_version' + '=' + '"' + oauth_version + '"' # Do not append comma and space to last parameter
    #
    # # Theoretically, this will work:
    # uri = URI.parse('https://api.twitter.com/1.1/friends/list.json')
    # request = Net::HTTP::Get.new(uri)
    # request['Authorization'] = authorization_header
    # request['Host'] = 'api.twitter.com'
    # request['X-Target-URI'] = 'https://api.twittter.com'
    # request['Connection'] = 'Keep-Alive'
    #
    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }
    #
    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end
    #
    # puts response.body

    # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
    def prepare_access_token(oauth_token, oauth_token_secret)
        consumer = OAuth::Consumer.new(ENV['TWITTER_ID'], ENV['TWITTER_SECRET'], { :site => "https://api.twitter.com", :scheme => :header })

        # now create the access token object from passed values
        token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
        access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

        return access_token
    end

    # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
    access_token = prepare_access_token(current_user.twitter_token, current_user.twitter_secret)

    # use the access token as an agent to get the home timeline
    response = access_token.request(:get, "https://api.twitter.com/1.1/friends/list.json?count=200&user_id=" + current_user.twitter_uid + "&skip_status=false&cursor=-1")

    write = JSON.parse response.body.gsub('=>', ':')

    if write["errors"] && write["errors"].first["message"] == "Rate limit exceeded"
      flash[:notice] = "Twitter says you're syncing your account too much! Try syncing later."
      return
    end

    next_cursor = write["next_cursor_str"]

    twitter_users = []

    number_of_requests = 1

    while next_cursor != "-1" && (number_of_requests < 15) # Wow a magic number, Ian, stellar fucking coding there bud

      if write["errors"] && write["errors"].first["message"] == "Rate limit exceeded"
        flash[:notice] = "Twitter says you're syncing your account too much! Try syncing later."
        return
      end

      puts response.body
      write["users"].each do |twit|
        twitter_users << twit
      end
      access_token = prepare_access_token(current_user.twitter_token, current_user.twitter_secret)

      response = access_token.request(:get, "https://api.twitter.com/1.1/friends/list.json?count=200&user_id=" + current_user.twitter_uid + "&skip_status=false&cursor=" + next_cursor)

      write = JSON.parse response.body.gsub('=>', ':')
      next_cursor = write["next_cursor_str"]
      number_of_requests = number_of_requests + 1
    end

    write["users"].each do |twit|
      twitter_users << twit
    end

    @new_pages = []
    @friends = []

    twitter_users.each do |page|

      page["profile_image_url_https"].slice! "_normal"

      @friends << page["id"]

      new_page = {
        :platform_id => page["id"].to_s,
        :page_name => page["name"],
        :page_image_url => page["profile_image_url_https"],
        :follow_count => page["followers_count"],
        :platform_url => 'https://www.twitter.com/' + page["screen_name"],
        :platform_name => 'Twitter',
        :description => page["description"],
        :banner_image_url => page["profile_banner_url"],
        :location => page["location"],
      }

      if page["status"] && page["status"]["text"]
        new_page[:recent_post_message] = page["status"]["text"]
      end

      @new_pages << new_page
    end

    SocialPageSaveWorker.perform_async(@new_pages, current_user.id)

    @friends.each do |friend|
      user = User.find_by(twitter_uid: friend)
      if user
        if !current_user.following.where(twitter_uid: user.twitter_uid).first
          current_user.following << user
        end
        if user.social_pages_list.where(platform_id: current_user.twitter_uid)
          if !user.following.where(twitter_uid: current_user.twitter_uid).first
            user.following << current_user
          end
        end
      end
    end


  end
end
