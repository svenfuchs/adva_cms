class AddFilterToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :filter, :string
  end

  def self.down
    remove_column :issues, :filter
  end
end
