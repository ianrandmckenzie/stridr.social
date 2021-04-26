class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|

      t.belongs_to :category, index: true
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
