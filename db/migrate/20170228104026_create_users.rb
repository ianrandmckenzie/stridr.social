class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|

      # Social APIs (Alphabetical order)
      t.string :facebook_token
      t.string :google_token
      t.string :pinterest_token
      t.string :tumblr_secret
      t.string :tumblr_token
      t.string :twitter_username
      # :youtube_token – see :google_token (DO NOT UNCOMMENT THIS)

      # Profile Info
      t.string :image
      t.string :username
      t.timestamps
    end
  end
end
