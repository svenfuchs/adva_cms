class AddContentTypeToAssetAssignments < ActiveRecord::Migration
  def self.up
    # a safety net if previously migrated. sorry
    return if columns(:asset_assignments).collect(&:name).include?("content_type")
    add_column :asset_assignments, :content_type, :string
    return unless table_exists?(:contents)
    execute 'UPDATE asset_assignments SET content_type = (SELECT type from contents WHERE contents.id = asset_assignments.content_id)'
  end
  
  def self.down
    remove_column :asset_assignments, :content_type
  end
end