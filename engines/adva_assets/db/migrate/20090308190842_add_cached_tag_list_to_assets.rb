class AddCachedTagListToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :cached_tag_list, :string
  end

  def self.down
    remove_column :assets, :cached_tag_list
  end
end
