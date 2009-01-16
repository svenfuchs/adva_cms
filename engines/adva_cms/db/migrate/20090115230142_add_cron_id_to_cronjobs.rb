class AddCronIdToCronjobs < ActiveRecord::Migration
  def self.up
    add_column :cronjobs, :cron_id, :string
  end

  def self.down
    remove_column :cronjobs, :cron_id
  end
end
