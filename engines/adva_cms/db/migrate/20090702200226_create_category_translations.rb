class CreateCategoryTranslations < ActiveRecord::Migration
  def self.up
    Category.create_translation_table! :title => :string
  end

  def self.down
    Category.drop_translation_table
  end
end
