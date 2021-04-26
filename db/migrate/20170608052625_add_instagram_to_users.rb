class AddInstagramToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :instagram_token, :string
    add_column :users, :instagram_uid, :string
  end
end
