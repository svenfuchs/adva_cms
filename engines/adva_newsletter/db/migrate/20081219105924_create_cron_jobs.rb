class CreateCronJobs < ActiveRecord::Migration
  def self.up
    create_table :cron_jobs do |t|
      t.integer :cornable_id, :null => false
      t.string  :cornable_type, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :cron_jobs
  end
end
