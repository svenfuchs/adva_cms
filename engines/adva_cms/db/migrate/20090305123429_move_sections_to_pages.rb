class MoveSectionsToPages < ActiveRecord::Migration
  def self.up
    Section.update_all "type = 'Page'", "type = 'Section' OR type IS NULL"
  end

  def self.down
    Section.update_all "type = NULL", "type = 'Page'"
  end
end
