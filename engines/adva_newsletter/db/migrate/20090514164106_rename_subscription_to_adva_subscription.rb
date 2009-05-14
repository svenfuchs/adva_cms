class RenameSubscriptionToAdvaSubscription < ActiveRecord::Migration
  def self.up
    rename_table :subscriptions, :adva_subscriptions
  end

  def self.down
    rename_table :adva_subscriptions, :subscriptions
  end
end
