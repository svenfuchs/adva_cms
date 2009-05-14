class RenameIssuesToAdvaIssues < ActiveRecord::Migration
  def self.up
    rename_table :issues, :adva_issues
  end

  def self.down
    rename_table :adva_issues, :issues
  end
end
