class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :social_page
end
