class AddGoogleAnalyticsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :google_analytics_tracking_code, :string
  end

  def self.down
    remove_column :sites, :google_analytics_tracking_code
  end
end
