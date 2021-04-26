class AddTwitchToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :twitch_token, :string
    add_column :users, :twitch_uid, :string
  end
end
