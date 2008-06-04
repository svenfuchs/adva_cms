class CreateCachedPageReferences < ActiveRecord::Migration
  def self.up
    create_table :cached_page_references, :force => true do |t|
      t.references :cached_page
      t.integer    :object_id
      t.string     :object_type
      t.string     :method
    end
  end
  
  def self.down
    drop_table :cached_page_references
  end
end