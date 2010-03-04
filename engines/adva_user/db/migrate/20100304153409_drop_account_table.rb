class DropAccountTable < ActiveRecord::Migration

  def self.up
    drop_table :accounts
  end

  def self.down
    create_table :accounts do |t|
      t.string :name
      
      t.timestamps
    end
  end

end
