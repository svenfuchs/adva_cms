class AddContentTypeToAssetAssignments < ActiveRecord::Migration
  def self.up
    # a safety net if previously migrated. sorry
    return if AssetAssingment.new.attributes_before_type_cast.has_key?('content_type')
    add_column :asset_assignments, :content_type, :string
    execute 'UPDATE asset_assignments SET content_type = (SELECT type from contents WHERE contents.id = asset_assignments.content_id)'
  end
  
  def self.down
    remove_column :asset_assignments, :content_type
  end
end