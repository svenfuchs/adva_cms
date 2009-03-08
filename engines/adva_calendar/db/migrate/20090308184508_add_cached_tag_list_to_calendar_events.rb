class AddCachedTagListToCalendarEvents < ActiveRecord::Migration
  def self.up
    add_column :calendar_events, :cached_tag_list, :string
  end

  def self.down
    remove_column :calendar_events, :cached_tag_list
  end
end
