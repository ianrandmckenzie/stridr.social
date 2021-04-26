class AddUnauthorizedAccountsListToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :unauthorized_accounts, :string, array: true, default: []
  end
end
