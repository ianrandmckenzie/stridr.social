class AddLastPostDateToSocialPages < ActiveRecord::Migration[5.0]
  def change
    add_column :social_pages, :recent_post_date, :integer
  end
end
