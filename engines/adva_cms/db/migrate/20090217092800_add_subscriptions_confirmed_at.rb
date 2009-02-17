class AddSubscriptionsConfirmedAt < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :confirmed_at, :datetime
  end

  def self.down
    remove_column :subscriptions, :confirmed_at
  end
end