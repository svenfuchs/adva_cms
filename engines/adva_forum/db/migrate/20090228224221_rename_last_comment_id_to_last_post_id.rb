class RenameLastCommentIdToLastPostId < ActiveRecord::Migration
  def self.up
    rename_column :boards, :last_comment_id, :last_post_id
    rename_column :topics, :last_comment_id, :last_post_id
    remove_column :topics, :comments_count
  end

  def self.down
    rename_column :boards, :last_post_id, :last_comment_id
    rename_column :topics, :last_post_id, :last_comment_id
    add_column :topics, :comments_count, :integer, :default => 0
  end
end
