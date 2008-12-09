class AddLocationIdToCalendarEvents < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :location_id, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :calendar_events, :location_id
  end
end