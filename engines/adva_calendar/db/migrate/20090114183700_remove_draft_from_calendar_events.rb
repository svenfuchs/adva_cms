class RemoveDraftFromCalendarEvents < ActiveRecord::Migration
  def self.up
    remove_column :calendar_events, :draft
  end

  def self.down
    add_column :calendar_events, :draft, :boolean, :null => false, :default => false
  end
end