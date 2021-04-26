class AddDeviantArtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deviantart_token, :string
    add_column :users, :deviantart_uid, :string
  end
end
