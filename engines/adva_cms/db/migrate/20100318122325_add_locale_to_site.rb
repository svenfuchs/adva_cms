class AddLocaleToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :locale, :string
  end

  def self.down
    remove_column :sites, :locale
  end
end
