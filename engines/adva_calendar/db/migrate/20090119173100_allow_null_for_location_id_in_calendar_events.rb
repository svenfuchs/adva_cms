class AllowNullForLocationIdInCalendarEvents < ActiveRecord::Migration
  def self.up
    change_column :calendar_events, :location_id, :integer, :null => true
  end

  def self.down
    change_column :calendar_events, :location_id, :integer, :null => false, :default => 1
  end
end