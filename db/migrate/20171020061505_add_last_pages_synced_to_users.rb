class AddLastPagesSyncedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_recent_posts_sync, :datetime, default: 1.day.ago
  end
end
