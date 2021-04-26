class AddFeedStatusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :feed_status, :string
  end
end
