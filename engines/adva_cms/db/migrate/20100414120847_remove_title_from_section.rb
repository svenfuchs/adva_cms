class RemoveTitleFromSection < ActiveRecord::Migration
  def self.up
    remove_column :sections, :title
  end

  def self.down
    add_column :sections, :title, :string
  end
end
