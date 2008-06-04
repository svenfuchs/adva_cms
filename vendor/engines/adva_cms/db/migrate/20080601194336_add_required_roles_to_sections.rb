class AddRequiredRolesToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :required_roles, :string
  end

  def self.down
    remove_column :sections, :required_roles
  end
end
