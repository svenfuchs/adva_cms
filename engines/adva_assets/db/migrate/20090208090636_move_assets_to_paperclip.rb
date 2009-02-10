class MoveAssetsToPaperclip < ActiveRecord::Migration
  def self.up
    remove_column :asset_assignments, :content_type

    add_column    :assets, :data_file_name,    :string
    add_column    :assets, :data_content_type, :string
    add_column    :assets, :data_file_size,    :integer
    add_column    :assets, :data_updated_at,   :datetime

    remove_column :assets, :parent_id
    remove_column :assets, :size
    remove_column :assets, :thumbnail
    remove_column :assets, :width
    remove_column :assets, :height
    remove_column :assets, :thumbnails_count
  end

  def self.down
    add_column :asset_assignments, :content_type, :string

    add_column :assets, :parent_id,        :integer
    add_column :assets, :size,             :integer
    add_column :assets, :thumbnail,        :string
    add_column :assets, :width,            :integer
    add_column :assets, :height,           :integer
    add_column :assets, :thumbnails_count, :integer
  end
end
