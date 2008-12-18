class AddParentIdToPhotos < ActiveRecord::Migration
  def self.up
    add_column    :photos, :parent_id, :integer
    remove_column :photos, :permalink
  end

  def self.down
    remove_column :photos, :parent_id
    add_column    :photos, :permalink, :string
  end
end
