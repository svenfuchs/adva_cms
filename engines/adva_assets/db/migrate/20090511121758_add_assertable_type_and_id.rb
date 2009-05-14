class AddAssertableTypeAndId < ActiveRecord::Migration
  def self.up
    add_column :assets, :assetable_type, :string
    add_column :assets, :assetable_id, :integer
  end

  def self.down
    remove_column :assets, :assetable_type
    remove_column :assets, :assetable_id
  end
end
