class AddIndexesForPageCachingTables < ActiveRecord::Migration
  def self.up
    add_index :cached_pages, [:site_id, :url]
    add_index :cached_page_references, [:object_id, :object_type]
  end

  def self.down
    remove_index :cached_page_references, [:object_id, :object_type]
    remove_index :cached_pages, [:site_id, :url]
  end
end
