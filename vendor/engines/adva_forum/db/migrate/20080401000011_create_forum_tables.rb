class CreateForumTables < ActiveRecord::Migration
  def self.up
    create_table :topics, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :title
      t.integer    :sticky,          :default => 0
      t.boolean    :locked,          :default => false
      t.integer    :comments_count,  :default => 0
      t.integer    :hits,            :default => 0
      t.integer    :last_comment_id
      t.references :last_author, :polymorphic => true
      t.string     :last_author_name
      t.string     :permalink
      t.timestamps
      t.datetime   :last_updated_at
    end

    # add_index "topics", ["sticky", "last_updated_at", "section_id"], :name => "index_topics_on_sticky_and_last_updated_at"
    # add_index "topics", ["last_updated_at", "section_id"], :name => "index_topics_on_section_id_and_last_updated_at"
    # add_index "topics", ["section_id", "permalink"], :name => "index_topics_on_section_id_and_permalink"
  end

  def self.down
    drop_table :topics
    # drop_table :posts
  end
end
