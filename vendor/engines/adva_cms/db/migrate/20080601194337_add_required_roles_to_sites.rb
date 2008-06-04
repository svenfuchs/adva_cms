class AddRequiredRolesToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :required_roles, :string
  end

  def self.down
    remove_column :sites, :required_roles
  end
end
