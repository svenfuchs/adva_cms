class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :type, :limit => 20
      t.integer    :position
      
      t.string     :title
      t.string     :permalink
      
      t.references :author, :polymorphic => true
      t.string     :author_name, :limit => 40
      t.string     :author_email, :limit => 40
      t.string     :author_homepage
      
      t.integer    :version
      t.string     :filter
      t.integer    :comment_age, :default => 0
      t.string     :cached_tag_list

      t.datetime   :published_at
      t.timestamps
    end
    Photo.create_versioned_table
  end

  def self.down
    drop_table :photos
    Photo.drop_versioned_table
  end
end
