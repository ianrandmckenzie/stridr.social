class AddRedditToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :reddit_token, :string
    add_column :users, :reddit_uid, :string
  end
end
