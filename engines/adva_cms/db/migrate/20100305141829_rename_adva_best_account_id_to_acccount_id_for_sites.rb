class RenameAdvaBestAccountIdToAcccountIdForSites < ActiveRecord::Migration
  def self.up
    rename_column :sites, :adva_best_account_id, :account_id
  end

  def self.down
    rename_column :sites, :account_id, :adva_best_account_id
  end
end
