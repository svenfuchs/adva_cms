class CreateAssetsTable < ActiveRecord::Migration
  def self.up
    create_table :asset_assignments, :force => true do |t|
      t.integer  :content_id
      t.integer  :asset_id
      t.integer  :position
      t.string   :label
      t.datetime :created_at
      t.boolean  :active
    end

    create_table :assets, :force => true do |t|
      t.integer  :site_id
      t.integer  :parent_id
      t.integer  :user_id
      t.string   :content_type
      t.string   :filename
      t.integer  :size
      t.string   :thumbnail
      t.integer  :width
      t.integer  :height
      t.string   :title
      t.integer  :thumbnails_count, :default => 0
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :asset_assignments
    drop_table :assets
  end
end