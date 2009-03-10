class RenameCronJobToCronjob < ActiveRecord::Migration
  def self.up
    rename_table :cron_jobs, :cronjobs
  end

  def self.down
    rename_table :cronjobs, :cron_jobs
  end
end
