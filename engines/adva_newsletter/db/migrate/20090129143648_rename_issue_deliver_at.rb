class RenameIssueDeliverAt < ActiveRecord::Migration
  def self.up
    rename_column :issues, :publish_at, :deliver_at
  end

  def self.down
    rename_column :issues, :deliver_at, :publish_at
  end
end
