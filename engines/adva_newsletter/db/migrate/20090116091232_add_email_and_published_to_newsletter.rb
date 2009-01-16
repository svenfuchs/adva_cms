class AddEmailAndPublishedToNewsletter < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :email, :string
    add_column :newsletters, :published, :integer, :default => 1
  end

  def self.down
    remove_column :newsletters, :email
    remove_column :newsletters, :published
  end
end
