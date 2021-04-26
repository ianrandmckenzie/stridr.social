class AddSelfReferenceToSocialPages < ActiveRecord::Migration[5.0]
  def change
    add_reference :social_pages, :main_page, index: true
    add_reference :social_pages, :relevances, index: true
  end
end
