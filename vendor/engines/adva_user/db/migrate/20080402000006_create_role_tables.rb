class CreateRoleTables < ActiveRecord::Migration
  def self.up
    create_table :roles do |t| 
      t.references :user # TODO reference a membership instead?
      t.references :context, :polymorphic => true
      t.string     :type, :limit => 25
    end
  end

  def self.down
    drop_table :roles
  end
end