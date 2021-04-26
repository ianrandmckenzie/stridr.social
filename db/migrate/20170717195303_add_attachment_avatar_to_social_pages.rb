class AddAttachmentAvatarToSocialPages < ActiveRecord::Migration
  def self.up
    change_table :social_pages do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :social_pages, :avatar
  end
end
