class AddFacebookExpiryToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :facebook_expiry, :datetime, default: DateTime.now
  end
end
