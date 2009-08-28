class MigrateRolesTableToNewRbac < ActiveRecord::Migration
  def self.up
    rename_column :roles, :type, :name
    add_column :roles, :ancestor_context_id, :integer
    add_column :roles, :ancestor_context_type, :string
    Rbac::Role.all.each { |role| role.update_attribute(:name, role.name.demodulize.underscore) }
  end

  def self.down
    Role.all.each { |role| role.update_attribute(:name, "Rbac::Role::#{role.name.camelize}") }
    remove_column :roles, :ancestor_context_id
    remove_column :roles, :ancestor_context_type
    rename_column :roles, :name, :type
  end
end