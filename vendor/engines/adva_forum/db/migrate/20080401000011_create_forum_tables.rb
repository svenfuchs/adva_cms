class CreateForumTables < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.references :site
      t.references :section
      t.references :topic
      t.references :user
      t.text       :body
      t.text       :body_html
      t.timestamps
    end

    create_table :topics, :force => true do |t|
      t.references :site
      t.references :section
      t.references :user
      t.string     :title
      t.integer    :sticky,          :default => 0
      t.boolean    :locked,          :default => false
      t.integer    :posts_count,     :default => 0
      t.integer    :hits,            :default => 0
      t.integer    :last_post_id
      t.datetime   :last_updated_at
      t.integer    :last_profile_id
      t.string     :permalink
      t.timestamps
    end

    # add_index "topics", ["sticky", "last_updated_at", "section_id"], :name => "index_topics_on_sticky_and_last_updated_at"
    # add_index "topics", ["last_updated_at", "section_id"], :name => "index_topics_on_section_id_and_last_updated_at"
    # add_index "topics", ["section_id", "permalink"], :name => "index_topics_on_section_id_and_permalink"
  end

  def self.down
    drop_table :topics
    drop_table :posts
  end
end
