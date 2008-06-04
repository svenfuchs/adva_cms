require File.dirname(__FILE__) + '/../test_helper'
require 'rails_generator'
require 'rails_generator/scripts/generate'

class MigrationsTest < Test::Unit::TestCase
  
  @@migration_dir = "#{RAILS_ROOT}/db/migrate"

  def setup
    ActiveRecord::Migration.verbose = false
    Engines.plugins[:test_migration].migrate(0)
  end
  
  def teardown
    FileUtils.rm_r(@@migration_dir) if File.exist?(@@migration_dir)
  end
  
  def test_engine_migrations_dont_run_anything_when_migrating_from_0_to_0
    Engines.plugins[:test_migration].migrate(0)
    assert tables_do_not_exist?('tests', 'others', 'timestamped', 'other_timestamped')
  end
  
  def test_engine_migrations_can_run_down
    Engines.plugins[:test_migration].migrate(20080428000001)
    Engines.plugins[:test_migration].migrate(0)
    assert tables_do_not_exist?('tests', 'others', 'timestamped', 'other_timestamped')
  end
    
  def test_engine_migrations_can_run_up
    Engines.plugins[:test_migration].migrate(2)
    assert tables_exist?('tests', 'others')
  end
    
  def test_engine_migrations_can_run_up_to_timestamped_migrations
    Engines.plugins[:test_migration].migrate(20080428000001)
    assert tables_exist?('tests', 'others', 'timestamped', 'other_timestamped')
  end
    
  def test_engine_migrations_can_run_one_step_down_from_to_timestamped_migrations
    Engines.plugins[:test_migration].migrate(20080428000001)
    Engines.plugins[:test_migration].migrate(20080428000000)
    assert tables_exist?('tests', 'others', 'timestamped')
    assert table_does_not_exist?('other_timestamped')
  end
    
  def test_generator_creates_plugin_migration_file
    Rails::Generator::Scripts::Generate.new.run(['plugin_migration', 'test_migration'], :quiet => true)
    assert migration_file, "migration file is missing"
  end
  
  private
  
  def table_exists?(table)
    ActiveRecord::Base.connection.tables.include?(table)
  end
  
  def tables_exist?(*tables)
    reduce_with_logical_and(tables){|table| table_exists?(table) }
  end
  
  def table_does_not_exist?(table)
    !ActiveRecord::Base.connection.tables.include?(table)
  end
  
  def tables_do_not_exist?(*tables)
    reduce_with_logical_and(tables){|table| table_does_not_exist?(table) }
  end
  
  def reduce_with_logical_and(values)
    values.map!{|value| yield value} if block_given?
    values.inject(true){|a, b| a && b }
  end
  
  def migration_file
    Dir["#{@@migration_dir}/*_test_migration_to_version_*.rb"][0]
  end
end

class MigrationsFilenameTest < Test::Unit::TestCase
  
  def setup
    ActiveRecord::Migration.verbose = false
    @generator = PluginMigrationGenerator.new []
    @generator.instance_variable_set(:@new_versions, {'plugin' => 0})
    @plugin = stub('plugin', :name => 'plugin')
  end
  
  def test_generator_descriptive_migration_name
    @generator.instance_variable_set :@plugins_to_migrate, [@plugin]
    assert_equal @generator.send(:build_migration_name), 'plugin_to_version_0'
  end
  
  def test_generator_uses_descriptive_migration_name_if_possible
    @generator.instance_variable_set :@plugins_to_migrate, [@plugin] * 9
    assert returns_descriptive_name?
  end
  
  def test_generator_uses_short_migration_name_if_exceeds_limit
    @generator.instance_variable_set :@plugins_to_migrate, [@plugin] * 10
    assert returns_short_name?
  end

  private
  
    def returns_descriptive_name?
      @generator.send(:build_migration_name) == @generator.send(:descriptive_migration_name)
    end
    
    def returns_short_name?
      @generator.send(:build_migration_name) == @generator.send(:short_migration_name)      
    end
end