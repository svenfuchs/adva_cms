class CreateContentsTable < ActiveRecord::Migration
  def self.up
    create_table :contents, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :type, :limit => 20
      t.integer    :position

      t.string     :permalink
      t.text       :excerpt_html
      t.text       :body_html

      t.references :author, :polymorphic => true
      t.string     :author_name, :limit => 40
      t.string     :author_email, :limit => 40
      t.string     :author_homepage

      t.integer    :version
      t.string     :filter
      t.integer    :comment_age, :default => 0
      t.string     :cached_tag_list
      t.integer    :assets_count, :default => 0

      t.datetime   :published_at
      t.timestamps
    end
    Content.create_translation_table! :title => :string, :body => :text,
      :excerpt => :text, :body_html => :text, :excerpt_html => :text
  end

  def self.down
    drop_table :contents
    Content.drop_translation_table
  end
end
