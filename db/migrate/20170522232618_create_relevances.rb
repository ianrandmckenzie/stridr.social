class CreateRelevances < ActiveRecord::Migration[5.0]
  def change
    create_table :relevances do |t|

      t.belongs_to :category, index: true
      t.belongs_to :social_page, index: true
      t.timestamps
    end
  end
end
