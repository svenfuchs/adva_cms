class CreateThemesTables < ActiveRecord::Migration
  def self.up
    create_table :themes, :force => true do |t|
      t.belongs_to :site
      t.string  :name
      t.string  :theme_id
      t.string  :author
      t.string  :version
      t.string  :homepage
      t.text    :summary
      t.integer :active
      t.timestamps
    end

    create_table :theme_files, :force => true do |t|
      t.belongs_to :theme
      t.string   :type
      t.string   :name
      t.string   :directory
      t.string   :data_file_name
      t.string   :data_content_type
      t.integer  :data_file_size
      t.datetime :data_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :themes
    drop_table :theme_files
  end
end
