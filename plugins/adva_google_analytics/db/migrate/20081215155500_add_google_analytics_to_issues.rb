class AddGoogleAnalyticsToIssues < ActiveRecord::Migration
  def self.up
    # FIXME check if table exists!
    add_column :issues, :track, :boolean, :default => false
    add_column :issues, :tracking_campaign, :string
    add_column :issues, :tracking_source, :string
  end

  def self.down
    remove_column :issues, :track
    remove_column :issues, :tracking_campaign
    remove_column :issues, :tracking_source
  end
end
