class Category < ApplicationRecord
  acts_as_votable
  has_many :relevances
  has_many :topics

  has_many :social_pages, -> { distinct }, through: :relevances
  has_many :users, -> { distinct }, through: :topics
end
