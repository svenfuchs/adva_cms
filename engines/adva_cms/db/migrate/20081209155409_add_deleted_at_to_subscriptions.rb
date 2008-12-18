class AddDeletedAtToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :deleted_at, :datetime, :default => nil
  end

  def self.down
    remove_column :subscriptions, :deleted_at
  end
end
