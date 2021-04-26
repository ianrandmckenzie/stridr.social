class AddCustomDataToSocialPages < ActiveRecord::Migration[5.0]
  # Custom data added for Facebook, Pinterest, Tumblr, Twitter, and YouTube
  def change
    add_column :social_pages, :website, :string # Facebook
    add_column :social_pages, :recent_post_message, :string # Tumblr
    add_column :social_pages, :recent_post_url, :string # Tumblr
    add_column :social_pages, :recent_post_image_url, :string # Tumblr
    add_column :social_pages, :recent_post_video_url, :string # Tumblr, YouTube
    add_column :social_pages, :banner_image_url, :string # Twitter
    add_column :social_pages, :location, :string # Facebook, Twitter
    add_column :social_pages, :content_count, :integer # YouTube (videos), Pinterest (pins)
    add_column :social_pages, :boards_count, :integer # Pinterest (if user)
    add_column :social_pages, :board_creator, :string # First name + last name ONLY if a Pinterest board
  end
end
