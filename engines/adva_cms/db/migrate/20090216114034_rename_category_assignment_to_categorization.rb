class RenameCategoryAssignmentToCategorization < ActiveRecord::Migration
  def self.up
    rename_table :category_assignments, :categorizations
    rename_column :categorizations, :content_type, :categorizable_type
    rename_column :categorizations, :content_id, :categorizable_id
  end

  def self.down
    rename_column :categorizations, :categorizable_id, :content_id
    rename_column :categorizations, :categorizable_type, :content_type
    rename_table :categorizations, :category_assignments
  end
end
