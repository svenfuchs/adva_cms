class CreateAdvaBestAccounts < ActiveRecord::Migration
  def self.up
    create_table :adva_best_accounts do |t|
      t.string :host
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :adva_best_accounts
  end
end