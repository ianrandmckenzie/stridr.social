class AddBioOptionsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :min_recommendation, :integer, default: 3
    add_column :users, :max_recommendation, :integer, default: 10
    add_column :users, :location, :string
    add_column :users, :description, :string
    add_reference :users, :recommendations, index: true
    add_reference :users, :topics, index: true
  end
end
