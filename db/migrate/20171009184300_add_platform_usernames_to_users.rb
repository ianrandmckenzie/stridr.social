class AddPlatformUsernamesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pinterest_username, :string
    add_column :users, :reddit_username, :string
    add_column :users, :spotify_username, :string
    add_column :users, :twitch_username, :string
    add_column :users, :youtube_channel_id, :string
  end
end
