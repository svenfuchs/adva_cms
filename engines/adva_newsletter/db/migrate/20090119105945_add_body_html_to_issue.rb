class AddBodyHtmlToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :body_html, :text
  end

  def self.down
    remove_column :issues, :body_html
  end
end
