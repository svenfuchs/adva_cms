class AddTimestampsToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :created_at, :datetime
    add_column :sections, :updated_at, :datetime
  end
  
  def self.down
    remove_column :sections, :created_at
    remove_column :sections, :updated_at
  end
end