class PluginOwnerColumn < ActiveRecord::Migration
  def self.up
    remove_column :plugin_configs, :site_id
    add_column :plugin_configs, :owner_id, :integer
    add_column :plugin_configs, :owner_type, :string
  end
 
  def self.down
    add_column :plugin_configs, :site_id, :integer
    remove_column :plugin_configs, :owner_id
    remove_column :plugin_configs, :owner_type
  end
end