class AddPublishedAtToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :published_at, :datetime
    Section.all.reject { |s| s.class == Page && s.single_article_mode }.each { |s| s.update_attribute(:published_at, Time.current) }
  end

  def self.down
    remove_column :sections, :published_at
  end
end