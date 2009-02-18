class AddMetatagsToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :meta_author, :string
    add_column :contents, :meta_geourl, :string
    add_column :contents, :meta_copyright, :string
    add_column :contents, :meta_keywords, :string
    add_column :contents, :meta_description, :text
  end

  def self.down
    remove_column :contents, :meta_author
    remove_column :contents, :meta_geourl
    remove_column :contents, :meta_copyright
    remove_column :contents, :meta_keywords
    remove_column :contents, :meta_description
  end
end
