class AddLastSyncDateToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_sync_date, :datetime
  end
end
