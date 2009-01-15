class AddCronJobAttributes < ActiveRecord::Migration
  def self.up
    remove_column :cron_jobs, :due_at
    add_column    :cron_jobs, :minute, :string, :default => "*"
    add_column    :cron_jobs, :hour, :string, :default => "*"
    add_column    :cron_jobs, :day, :string, :default => "*"
    add_column    :cron_jobs, :month, :string, :default => "*"
    add_column    :cron_jobs, :weekday, :string, :default => "*"
  end

  def self.down
    add_column    :cron_jobs, :due_at, :datetime
    remove_column :cron_jobs, :minute
    remove_column :cron_jobs, :hour
    remove_column :cron_jobs, :day
    remove_column :cron_jobs, :month
    remove_column :cron_jobs, :weekday
  end
end
