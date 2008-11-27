class CreateLocationsTable < ActiveRecord::Migration
  def self.up
    create_table :locations, :force => true do |t|
      t.string :title, :null => false
      t.string :country
      t.string :town
      t.string :address
      t.string :postcode, :limit => 15
      t.text   :description

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end