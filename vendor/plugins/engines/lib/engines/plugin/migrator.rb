# The Plugin::Migrator class contains the logic to run migrations from
# within plugin directories. The directory in which a plugin's migrations
# should be is determined by the Plugin#migration_directory method.
#
# To migrate a plugin, you can simple call the migrate method (Plugin#migrate)
# with the version number that plugin should be at. The plugin's migrations
# will then be used to migrate up (or down) to the given version.
#
# For more information, see Engines::RailsExtensions::Migrations
class Engines::Plugin::Migrator < ActiveRecord::Migrator

  # We need to be able to set the 'current' engine being migrated.
  cattr_accessor :current_plugin

  # Runs the migrations from a plugin, up (or down) to the version given
  def self.migrate_plugin(plugin, version)
    self.current_plugin = plugin
    # There seems to be a bug in Rails' own migrations, where migrating
    # to the existing version causes all migrations to be run where that
    # migration number doesn't exist (i.e. zero). We could fix this by
    # removing the line if the version hits zero...?
    version = version.to_i unless version.nil?
    return if current_version(plugin) == version
    migrate(plugin.migration_directory, version)
  end
  
  # Returns the name of the table used to store schema information about
  # installed plugins.
  #
  # See Engines.schema_migrations_table for more details.
  def self.schema_migrations_table_name
    proper_table_name Engines.schema_migrations_table
  end

  # Returns the current version of the given plugin
  def self.current_version(plugin=current_plugin)
    # there might not be a plugin_schema_migrations table present at this
    # point so we'll rescue that and initialize the table
    result = begin
      ActiveRecord::Base.connection.select_one(%Q(
        SELECT version FROM #{schema_migrations_table_name} 
        WHERE plugin_name = '#{plugin.name}'
        ORDER BY version DESC))
    rescue
      ActiveRecord::Base.connection.initialize_schema_migrations_table
    end
    result.blank? ? 0 : result['version'].to_i
  end
  
  # Sets the version of the plugin in Engines::Plugin::Migrator.current_plugin to
  # the given version.
  def record_version_state_after_migrating(version)
    sm_table = self.class.schema_migrations_table_name
    if down?
      ActiveRecord::Base.connection.update(%Q(
        DELETE FROM #{sm_table} 
        WHERE plugin_name = '#{self.current_plugin.name}' AND version = '#{version}'))
    else
      ActiveRecord::Base.connection.insert(%Q(
        INSERT INTO #{sm_table} (plugin_name, version) 
        VALUES ('#{self.current_plugin.name}', '#{version}')))
    end
  end
end
