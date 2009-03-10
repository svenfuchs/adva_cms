class AddDueAtToCronJob < ActiveRecord::Migration
  def self.up
    add_column :cron_jobs, :due_at, :datetime
    add_column :cron_jobs, :command, :string
  end

  def self.down
    remove_column :cron_jobs, :due_at
    remove_column :cron_jobs, :command
  end
end
