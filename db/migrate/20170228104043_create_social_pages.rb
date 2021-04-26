class CreateSocialPages < ActiveRecord::Migration[5.0]
  def change
    create_table :social_pages do |t|

      # Page name/title
      t.string :page_name

      # Image provided by platform
      t.string :page_image_url

      # Follows or likes or their equivalent
      t.integer :follow_count

      # Platform URL
      t.string :platform_url

      # Platform Page ID
      t.string :platform_id

      # Platform name – used for identification purposes
      t.string :platform_name

      # Page description
      t.string :description

      t.timestamps
    end
  end
end
