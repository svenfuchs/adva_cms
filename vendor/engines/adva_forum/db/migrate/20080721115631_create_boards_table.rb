class CreateBoardsTable < ActiveRecord::Migration
  def self.up
    create_table :boards, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :title
      t.string     :permalink
      t.text       :description
      t.integer    :position
      t.integer    :last_comment_id
      t.references :last_author, :polymorphic => true
      t.string     :last_author_name
      t.timestamps
      t.datetime   :last_updated_at
    end

    add_column :topics, :board_id, :integer
  end

  def self.down
    drop_table :boards

    remove_column :topics, :board_id
  end
end
