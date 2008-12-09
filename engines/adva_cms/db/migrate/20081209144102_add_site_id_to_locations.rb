class AddSiteIdToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :site_id, :integer, :null => false, :default => 1
    add_index :locations, :site_id
  end
  
  def self.down
    remove_index :locations, :site_id
    remove_column :locations, :site_id
  end
end