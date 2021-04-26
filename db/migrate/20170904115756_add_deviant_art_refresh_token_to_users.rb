class AddDeviantArtRefreshTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deviantart_refresh, :string
  end
end
