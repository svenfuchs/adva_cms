class AddContentTypeToJoinTables < ActiveRecord::Migration
  def self.up
    add_column :category_assignments, :content_type, :string
    execute 'UPDATE category_assignments SET content_type = (SELECT type from contents WHERE contents.id = category_assignments.content_id)'
  end
  
  def self.down
    remove_column :category_assignments, :content_type
  end
end