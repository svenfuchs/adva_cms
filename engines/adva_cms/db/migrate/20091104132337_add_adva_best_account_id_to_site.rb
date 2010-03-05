class AddAdvaBestAccountIdToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :adva_best_account_id, :integer
  end

  def self.down
    remove_column :sites, :adva_best_account_id
  end
end