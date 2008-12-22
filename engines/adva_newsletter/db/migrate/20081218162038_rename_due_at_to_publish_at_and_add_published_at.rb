class RenameDueAtToPublishAtAndAddPublishedAt < ActiveRecord::Migration
  def self.up
    rename_column :issues, :due_at, :publish_at
    add_column :issues, :published_at, :datetime
  end

  def self.down
    rename_column :issues, :published_at, :due_at
  end
end
