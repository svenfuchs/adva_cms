class CreateSectionTranslations < ActiveRecord::Migration
  def self.up
    Section.create_translation_table! :title => :string
  end

  def self.down
    Section.drop_translation_table
  end
end
