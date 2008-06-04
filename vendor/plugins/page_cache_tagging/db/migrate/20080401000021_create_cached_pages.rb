class CreateCachedPages < ActiveRecord::Migration
  def self.up
    create_table :cached_pages, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :url
      t.datetime   :updated_at
      t.datetime   :cleared_at
    end
  end
  
  def self.down
    drop_table :cached_pages
  end
end