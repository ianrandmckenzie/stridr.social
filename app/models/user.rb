class User < ApplicationRecord
  after_save :min_validate
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [
           :facebook,
           :google_oauth2,
           :pinterest,
           :tumblr,
           :twitter,
           :instagram,
           :twitch,
           :deviantart,
           :spotify,
           :reddit
         ]

  acts_as_voter

  has_many :interests
  has_many :recommendations
  has_many :topics
  # -> { distinct } prevents duplicate "interests" entries
  has_many :social_pages_list, -> { distinct }, through: :interests, source: :social_page
  has_many :recommended_social_pages, -> { distinct }, through: :recommendations, source: :social_page
  has_many :categories, -> { distinct }, through: :topics
  has_many :active_relationships,
    class_name:  "Relationship",
    foreign_key: "follower_id",
    dependent:   :destroy

  has_many :passive_relationships,
    class_name:  "Relationship",
    foreign_key: "followed_id",
    dependent:   :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  validates_confirmation_of :password

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      if auth.provider.downcase == 'twitter'
        user.twitter_username = auth.info.nickname
        user.twitter_token = auth.credentials.token
        user.twitter_secret = auth.credentials.secret
        user.twitter_uid = auth.uid
      end
      if auth.provider.downcase == 'facebook'
        user.facebook_token = auth.credentials.token
        user.facebook_uid = auth.uid
      end
      if auth.provider.downcase == 'google_oauth2'
        user.google_token = auth.credentials.token
        user.google_uid = auth.uid
      end
      if auth.provider.downcase == 'twitch'
        user.twitch_token = auth.credentials.token
        user.twitch_uid = auth.uid
      end
      user.last_sync_date = DateTime.now
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.username = auth.info.name
      if auth.info.image
        auth.info.image = auth.info.image.sub! 'http://', 'https://'
        user.image = auth.info.image
      end

    end
  end

  has_attached_file :infographic, styles: { medium: "550x850>",
                                       thumb: "137x212>" },
                             default_url: "/images/:style/missing.png",
                             s3_protocol: :https
  validates_attachment :infographic,
  content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  # Prevent impossible recommendation scope
  private
  def min_validate
    if self.min_recommendation > self.max_recommendation
      self.min_recommendation = self.max_recommendation - 1
      self.save
    end
  end
end
