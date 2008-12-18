class ChangeLocationId < ActiveRecord::Migration
  def self.up
    change_column :calendar_events, :location_id, :integer, :default => nil, :nil => true
  end

  def self.down
  end
end