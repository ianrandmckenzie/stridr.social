class AddWordsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :favorite_words, :string
    add_column :users, :least_favorite_words, :string
  end
end
