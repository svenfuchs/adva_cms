class AddCommentBoardId < ActiveRecord::Migration
  def self.up
    add_column :comments, :board_id, :integer
  end

  def self.down
    remove_column :comments, :board_id
  end
end
