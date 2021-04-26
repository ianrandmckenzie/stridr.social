class SocialPage < ApplicationRecord
  acts_as_votable
  has_many :relevances
  has_many :interests
  has_many :categories, -> { distinct }, through: :relevances
  # -> { distinct } prevents duplicate "interests" entries
  has_many :users, -> { distinct }, through: :interests
  has_many :users, -> { distinct }, through: :recommendations

  # I couldn't think of better wording for the type of wording to be used for
  # self-referencing social pages, so I just did a blatant copy-pasta of
  # the user following structure. I'm going to be so embarrassed if I ever
  # have to hand this app off to real programmers. If you're one of said
  # programmers, consider this one of many apologies. -Ian
  has_many :active_suggestions,
    class_name:  "Suggestion",
    foreign_key: "follower_id",
    dependent:   :destroy

  has_many :passive_suggestions,
    class_name:  "Suggestion",
    foreign_key: "followed_id",
    dependent:   :destroy

  has_many :following, through: :active_suggestions, source: :followed
  has_many :followers, through: :passive_suggestions, source: :follower

  has_attached_file :avatar, styles: { medium: "400x400>",
                                       thumb: "100x100>" },
                             default_url: "/images/:style/missing.png",
                             s3_protocol: :https
  validates_attachment :avatar,
  content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  def thumb_avatar_url
    avatar.url(:thumb)
  end

  def medium_avatar_url
    avatar.url(:medium)
  end

  def stridr_followers
    get_likes.size
  end
end
