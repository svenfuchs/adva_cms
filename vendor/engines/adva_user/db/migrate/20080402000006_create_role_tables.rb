class CreateRoleTables < ActiveRecord::Migration
  def self.up
    create_table :roles do |t| 
      t.references :user # TODO reference a membership instead?
      t.references :object, :polymorphic => true
      t.string     :name
    end
  end

  def self.down
    drop_table :roles
  end
end