class AddGoogleAnalyticsToIssues < ActiveRecord::Migration
  def self.up
    if table_exists?(:issues)
      add_column :issues, :track, :boolean, :default => false
      add_column :issues, :tracking_campaign, :string
      add_column :issues, :tracking_source, :string
    end
  end

  def self.down
    if table_exists?(:issues)
      remove_column :issues, :track
      remove_column :issues, :tracking_campaign
      remove_column :issues, :tracking_source
    end
  end
end
