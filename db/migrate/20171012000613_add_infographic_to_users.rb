class AddInfographicToUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.attachment :infographic
    end
  end

  def self.down
    remove_attachment :users, :infographic
  end
end
