class AddContentTypeToJoinTables < ActiveRecord::Migration
  def self.up
    add_column :asset_assignments, :content_type, :string
    execute 'UPDATE asset_assignments SET content_type = (SELECT type from contents WHERE contents.id = asset_assignments.content_id)'
    
    add_column :category_assignments, :content_type, :string
    execute 'UPDATE category_assignments SET content_type = (SELECT type from contents WHERE contents.id = category_assignments.content_id)'
  end
  
  def self.down
    remove_column :category_assignments, :content_type
    remove_column :asset_assignments, :content_type
    
  end
end