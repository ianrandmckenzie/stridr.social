class AddFilterToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deviantart_filter, :boolean, default: false
    add_column :users, :facebook_filter, :boolean, default: false
    add_column :users, :instagram_filter, :boolean, default: false
    add_column :users, :pinterest_filter, :boolean, default: false
    add_column :users, :reddit_filter, :boolean, default: false
    add_column :users, :spotify_filter, :boolean, default: false
    add_column :users, :tumblr_filter, :boolean, default: false
    add_column :users, :twitter_filter, :boolean, default: false
    add_column :users, :twitch_filter, :boolean, default: false
    add_column :users, :youtube_filter, :boolean, default: false
  end
end
