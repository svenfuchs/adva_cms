class AddLocationToCalendarEvents < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :location, :string
  end

  def self.down
    remove_column :calendar_events, :location
  end
end