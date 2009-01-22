class AddQueuedAtToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :queued_at, :datetime
  end

  def self.down
    remove_column :issues, :queued_at
  end
end
