require File.join( File.dirname(__FILE__), '..', 'test_helper' )
require 'active_record'

begin
  require 'globalize/model/active_record'
rescue MissingSourceFile
  puts "This plugin requires the Globalize2 plugin: http://github.com/joshmh/globalize2/tree/master"
  puts
  raise
end

require 'globalize2_versioning'

# Hook up model translation
ActiveRecord::Base.send :include, Globalize::Model::ActiveRecord::Translated
ActiveRecord::Base.send :include, Globalize::Model::ActiveRecord::Versioned

# Load Section model
require File.join( File.dirname(__FILE__), '..', 'data', 'post' )

class VersionedModelMigrationTest < ActiveSupport::TestCase
  def setup
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'no_globalize_schema.rb'))
  end
  
  test 'globalize table added' do
    assert !Section.connection.table_exists?( :post_translations )
    Section.create_translation_table! :title => :string, :content => :text
    assert Section.connection.table_exists?( :section_translations )      
    columns = Section.connection.columns( :section_translations )
    assert locale = columns.detect {|c| c.name == 'locale' }
    assert_equal :string, locale.type
    assert title = columns.detect {|c| c.name == 'title' }
    assert_equal :string, title.type
    assert content = columns.detect {|c| c.name == 'content' }
    assert_equal :text, content.type
    assert section_id = columns.detect {|c| c.name == 'section_id' }
    assert_equal :integer, section_id.type
    assert created_at = columns.detect {|c| c.name == 'created_at' }
    assert_equal :datetime, created_at.type
    assert updated_at = columns.detect {|c| c.name == 'updated_at' }
    assert_equal :datetime, updated_at.type
    
    # versioning stuff
    assert version = columns.detect {|c| c.name == 'version' }
    assert_equal :integer, version.type
    
    assert current = columns.detect {|c| c.name == 'current' }
    assert_equal :boolean, current.type
  end
  
  test 'globalize table dropped' do
    assert !Section.connection.table_exists?( :section_translations )
    Section.create_translation_table! :title => :string, :content => :text
    assert Section.connection.table_exists?( :section_translations )      
    Section.drop_translation_table!
    assert !Section.connection.table_exists?( :section_translations )
  end

  test 'exception on untranslated field inputs' do
    assert_raise Globalize::Model::UntranslatedMigrationField do
      Section.create_translation_table! :title => :string, :content => :text, :bogus => :string
    end
  end
  
  test 'exception on missing field inputs' do
    assert_raise Globalize::Model::MigrationMissingTranslatedField do
      Section.create_translation_table! :content => :text
    end
  end
  
  test 'exception on bad input type' do
    assert_raise Globalize::Model::BadMigrationFieldType do
      Section.create_translation_table! :title => :string, :content => :integer
    end
  end
  
  test 'create_translation_table! should not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.create_translation_table! :name => :string      
    end
  end

  test 'drop_translation_table! should not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.drop_translation_table!      
    end
  end

end