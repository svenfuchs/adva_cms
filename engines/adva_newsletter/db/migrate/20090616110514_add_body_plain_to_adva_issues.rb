class AddBodyPlainToAdvaIssues < ActiveRecord::Migration
  def self.up
    add_column :adva_issues, :body_plain, :text
  end

  def self.down
    remove_column :adva_issues, :body_plain
  end
end
