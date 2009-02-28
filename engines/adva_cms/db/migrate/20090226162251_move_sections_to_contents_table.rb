class MoveSectionsToContentsTable < ActiveRecord::Migration
  def self.up
    add_column :contents, :parent_id, :integer
    add_column :contents, :lft, :integer, :null => false, :default => 0
    add_column :contents, :rgt, :integer, :null => false, :default => 0
    add_column :contents, :path, :string
    add_column :contents, :options, :text
    add_column :contents, :content_filter, :string
    add_column :contents, :permissions, :text

    # TODO[section_contents] migrate existing sections to contents

    drop_table :sections
  end

  def self.down
    create_table "sections", :force => true do |t|
      t.string  "type"
      t.integer "site_id"
      t.integer "parent_id"
      t.integer "lft",            :default => 0, :null => false
      t.integer "rgt",            :default => 0, :null => false
      t.string  "path"
      t.string  "permalink"
      t.string  "title"
      t.string  "layout"
      t.string  "template"
      t.text    "options"
      t.integer "contents_count"
      t.integer "comment_age"
      t.string  "content_filter"
      t.text    "permissions"
    end

    remove_column :contents, :parent_id
    remove_column :contents, :lft
    remove_column :contents, :rgt
    remove_column :contents, :path
    remove_column :contents, :options
    remove_column :contents, :content_filter
    remove_column :contents, :permissions
  end
end
