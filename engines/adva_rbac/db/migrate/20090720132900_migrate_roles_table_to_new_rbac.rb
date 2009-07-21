class MigrateRolesTableToNewRbac < ActiveRecord::Migration
  def self.up
    rename_column :roles, :type, :name
    Role.all.each { |role| role.update_attribute(:name, role.name.demodulize.underscore) }
  end

  def self.down
    Role.all.each { |role| role.update_attribute(:name, "Rbac::Role::#{role.name.camelize}") }
    rename_column :roles, :name, :type
  end
end