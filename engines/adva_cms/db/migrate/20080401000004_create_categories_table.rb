class CreateCategoriesTable < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.references  :section
      t.integer     :parent_id
      t.integer     :lft, :null => false, :default => 0
      t.integer     :rgt, :null => false, :default => 0
      t.string      :title
      t.string      :path
      t.string      :permalink
    end
  end

  def self.down
    drop_table :categories
  end
end
