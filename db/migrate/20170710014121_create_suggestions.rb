class CreateSuggestions < ActiveRecord::Migration[5.0]
  # I couldn't think of better wording for the type of wording to be used for
  # self-referencing social pages, so I just did a blatant copy-pasta of
  # the user following structure. I'm going to be so embarrassed if I ever
  # have to hand this app off to real programmers. If you're one of said
  # programmers, consider this one of many apologies. -Ian
  def change
    create_table :suggestions do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    add_index :suggestions, :follower_id
    add_index :suggestions, :followed_id
    add_index :suggestions, [:follower_id, :followed_id], unique: true
  end
end
