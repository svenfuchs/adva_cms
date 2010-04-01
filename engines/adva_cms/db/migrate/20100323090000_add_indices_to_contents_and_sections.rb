class AddIndicesToContentsAndSections < ActiveRecord::Migration
  def self.up
    add_index :content_translations, :content_id
    add_index :contents, :section_id
    add_index :sections, :parent_id
  end

  def self.down
    remove_index :sections, :column => :parent_id
    remove_index :contents, :column => :section_id
    remove_index :content_translations, :column => :content_id
  end
end
