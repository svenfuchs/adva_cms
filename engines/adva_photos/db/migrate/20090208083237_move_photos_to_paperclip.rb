class MovePhotosToPaperclip < ActiveRecord::Migration
  def self.up
    add_column    :photos, :data_file_name,    :string
    add_column    :photos, :data_content_type, :string
    add_column    :photos, :data_file_size,    :integer
    add_column    :photos, :data_updated_at,   :datetime

    remove_column :photos, :type
    remove_column :photos, :position
    remove_column :photos, :filter

    remove_column :photos, :content_type
    remove_column :photos, :filename
    remove_column :photos, :thumbnail
    remove_column :photos, :size
    remove_column :photos, :width
    remove_column :photos, :height
    remove_column :photos, :thumbnails_count
  end

  def self.down
    add_column    :photos, :type,             :string, :limit => 20
    add_column    :photos, :position,         :integer
    add_column    :photos, :filter,           :string

    add_column    :photos, :content_type,     :string
    add_column    :photos, :filename,         :string
    add_column    :photos, :thumbnail,        :string
    add_column    :photos, :size,             :integer
    add_column    :photos, :width,            :integer
    add_column    :photos, :height,           :integer
    add_column    :photos, :thumbnails_count, :integer, :default => 0

    add_column    :photos, :parent_id,        :integer
  end
end
