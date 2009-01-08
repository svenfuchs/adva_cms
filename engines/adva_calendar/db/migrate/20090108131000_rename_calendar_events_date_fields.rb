class RenameCalendarEventsDateFields < ActiveRecord::Migration
  def self.up
    rename_column :calendar_events, :startdate, :start_date
    rename_column :calendar_events, :enddate, :end_date
  end

  def self.down
    rename_column :calendar_events, :start_date, :startdate
    rename_column :calendar_events, :end_date, :enddate
  end
end