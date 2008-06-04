class CreateMembershipsTable < ActiveRecord::Migration
  def self.up
    create_table :memberships, :force => true do |t|
      t.references :site
      t.references :user
      t.timestamps
    end
  end
  
  def self.down
  end
end
