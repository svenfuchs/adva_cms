class RenameAdvaBestAccountsToAccounts < ActiveRecord::Migration
  def self.up
    rename_table :adva_best_accounts, :accounts
  end

  def self.down
    rename_table :accounts, :adva_best_accounts
  end
end
