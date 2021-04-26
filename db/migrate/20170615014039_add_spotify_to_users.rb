class AddSpotifyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :spotify_token, :string
    add_column :users, :spotify_uid, :string
  end
end
