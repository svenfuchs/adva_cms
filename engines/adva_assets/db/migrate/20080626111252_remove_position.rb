class RemovePosition < ActiveRecord::Migration
  def self.up
    remove_column :asset_assignments, :position
  end

  def self.down
    add_column :asset_assignments, :position, :integer
  end
end