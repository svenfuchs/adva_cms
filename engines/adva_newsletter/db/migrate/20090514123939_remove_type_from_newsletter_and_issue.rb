class RemoveTypeFromNewsletterAndIssue < ActiveRecord::Migration
  def self.up
    remove_column :newsletters, :type
    remove_column :issues, :type
  end

  def self.down
    add_column :newsletters, :type, :string
    add_column :issues, :type, :string
  end
end
