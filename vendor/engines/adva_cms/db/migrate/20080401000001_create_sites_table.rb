class CreateSitesTable < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string  :name
      t.string  :host
      t.string  :title
      t.string  :subtitle
      t.string  :email
      t.string  :timezone
      t.string  :theme_names
      t.text    :ping_urls
      t.string  :akismet_key, :limit => 100
      t.string  :akismet_url
      t.boolean :approve_comments
      t.integer :comment_age
      t.string  :comment_filter
      t.string  :search_path
      t.string  :tag_path
      t.string  :tag_layout
      t.string  :permalink_style
      t.text    :permissions
    end
  end

  def self.down
    drop_table :sites
  end
end
