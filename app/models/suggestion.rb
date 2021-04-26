class Suggestion < ApplicationRecord
  belongs_to :follower, class_name: "SocialPage"
  belongs_to :followed, class_name: "SocialPage"
end
