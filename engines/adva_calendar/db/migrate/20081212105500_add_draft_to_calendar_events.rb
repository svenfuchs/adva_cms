class AddDraftToCalendarEvents < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :draft, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :calendar_events, :draft
  end
end