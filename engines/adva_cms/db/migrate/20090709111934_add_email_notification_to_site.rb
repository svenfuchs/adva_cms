class AddEmailNotificationToSite < ActiveRecord::Migration

  # Throwaway - short term solution
  
  def self.up
    add_column :sites, :email_notification, :boolean, :default => false
  end
  
  def self.down
    remove_column :sites, :email_notification
  end
end