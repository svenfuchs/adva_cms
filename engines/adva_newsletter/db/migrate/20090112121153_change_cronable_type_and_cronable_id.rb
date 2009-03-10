class ChangeCronableTypeAndCronableId < ActiveRecord::Migration
  def self.up
    rename_column :cron_jobs, :cornable_type, :cronable_type
    rename_column :cron_jobs, :cornable_id, :cronable_id
    change_column :cron_jobs, :cronable_type, :string, :null => true
    change_column :cron_jobs, :cronable_id, :integer, :null => true
  end

  def self.down
    rename_column :cron_jobs, :cronable_type, :cornable_type
    rename_column :cron_jobs, :cronable_id, :cornable_id
    change_column :cron_jobs, :cornable_type, :string, :null => false
    change_column :cron_jobs, :cornable_id, :integer, :null => false
  end
end
