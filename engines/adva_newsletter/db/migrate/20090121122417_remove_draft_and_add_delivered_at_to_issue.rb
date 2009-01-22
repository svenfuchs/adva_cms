class RemoveDraftAndAddDeliveredAtToIssue < ActiveRecord::Migration
  def self.up
    remove_column :issues, :draft
    add_column :issues, :delivered_at, :datetime
  end

  def self.down
    add_column :issues, :draft, :integer
    remove_column :issues, :delivered_at
  end
end
