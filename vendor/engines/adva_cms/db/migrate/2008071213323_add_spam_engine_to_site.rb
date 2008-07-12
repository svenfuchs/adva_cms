class AddSpamEngineToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :spam_options, :text
  end

  def self.down
    remove_column :sites, :spam_options
  end
end
