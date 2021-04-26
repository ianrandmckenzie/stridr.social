class AddTwitterTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end
end
