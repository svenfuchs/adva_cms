class AddGoogleAnalyticsToAdvaIssues < ActiveRecord::Migration
  def self.up
    if table_exists?(:adva_issues)
      add_column :adva_issues, :track, :boolean, :default => false
      add_column :adva_issues, :tracking_campaign, :string
      add_column :adva_issues, :tracking_source, :string
    end
  end

  def self.down
    if table_exists?(:adva_issues)
      remove_column :adva_issues, :track
      remove_column :adva_issues, :tracking_campaign
      remove_column :adva_issues, :tracking_source
    end
  end
end
