class AddLoadingToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deviantart_loading, :boolean, default: false
    add_column :users, :facebook_loading, :boolean, default: false
    add_column :users, :instagram_loading, :boolean, default: false
    add_column :users, :pinterest_loading, :boolean, default: false
    add_column :users, :reddit_loading, :boolean, default: false
    add_column :users, :spotify_loading, :boolean, default: false
    add_column :users, :tumblr_loading, :boolean, default: false
    add_column :users, :twitter_loading, :boolean, default: false
    add_column :users, :twitch_loading, :boolean, default: false
    add_column :users, :youtube_loading, :boolean, default: false
  end
end
