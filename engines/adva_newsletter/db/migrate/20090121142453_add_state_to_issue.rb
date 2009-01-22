class AddStateToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :state, :string, :default => "draft"
  end

  def self.down
    remove_column :issues, :state
  end
end
