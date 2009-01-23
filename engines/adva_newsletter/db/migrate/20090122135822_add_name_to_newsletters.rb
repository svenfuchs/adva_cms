class AddNameToNewsletters < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :name, :string
  end

  def self.down
    remove_column :newsletters, :name
  end
end
