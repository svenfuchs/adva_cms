class AddTypeAndDeletedAtToIssuesNewsletters < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :type, :string
    add_column :newsletters, :deleted_at, :datetime, :default => nil
    add_column :issues, :type, :string
    add_column :issues, :deleted_at, :datetime, :default => nil
  end

  def self.down
    remove_column :newsletters, :deleted_at
    remove_column :newsletters, :type
    remove_column :issues, :deleted_at
    remove_column :issues, :type
  end
end
