class AddMetatagsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :meta_author, :string
    add_column :sites, :meta_geourl, :string
    add_column :sites, :meta_copyright, :string
    add_column :sites, :meta_keywords, :string
    add_column :sites, :meta_description, :text
  end

  def self.down
    remove_column :sites, :meta_author
    remove_column :sites, :meta_geourl
    remove_column :sites, :meta_copyright
    remove_column :sites, :meta_keywords
    remove_column :sites, :meta_description
  end
end