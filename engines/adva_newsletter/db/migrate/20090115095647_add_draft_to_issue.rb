class AddDraftToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :draft, :integer, :default => 1
  end

  def self.down
    remove_column :issues, :draft
  end
end
