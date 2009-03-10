# This test suite tests the versioned fields of the versioned model.

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

class VersionedFieldTest < ActiveSupport::TestCase
  def setup
    I18n.locale = :'en-US'
    I18n.fallbacks.clear 
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'schema.rb'))
  end
  
  test "modifiying translated fields" do
    section = Section.create :content => 'foo'
    assert_equal 'foo', section.content
    section.content = 'bar'
    assert_equal 'bar', section.content    
  end

  test "modifiying translated fields while switching locales" do
    section = Section.create :content => 'foo'
    assert_equal 'foo', section.content
    I18n.locale = :'de-DE'
    section.content = 'bar'
    assert_equal 'bar', section.content
    I18n.locale = :'en-US'
    assert_equal 'foo', section.content
    I18n.locale = :'de-DE'
    section.content = 'bar'
  end
  
  test "has section_translations" do
    section = Section.create
    assert_nothing_raised { section.globalize_translations }
  end

  test "returns the value passed to :content" do
    section = Section.new
    assert_equal 'foo', (section.content = 'foo')
  end

  test "translates content into en-US" do
    section = Section.create :content => 'foo'
    assert_equal 'foo', section.content 
    assert section.save
    section.reload
    assert_equal 'foo', section.content 
  end

  test "finds a German section" do
    section = Section.create :content => 'foo (en)'
    I18n.locale = 'de-DE'
    section = Section.first
    section.content = 'baz (de)'
    section.save
    assert_equal 'baz (de)', Section.first.content 
    I18n.locale = :'en-US'
    assert_equal 'foo (en)', Section.first.content 
  end

  test "saves an English section and loads test correctly" do
    assert_nil Section.first
    section = Section.create :content => 'foo'
    assert section.save
    section = Section.first
    assert_equal 'foo', section.content 
  end

  test "updates an attribute" do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'baz'
    assert_equal 'baz', Section.first.content 
  end

  test "validates presence of :content" do
    section = Section.new
    assert !section.save

    section = Section.new :content => 'foo'
    assert section.save
  end

  test "returns the value for the correct locale, after locale switching" do
    section = Section.create :content => 'foo'
    I18n.locale = 'de-DE'
    section.content = 'bar'
    section.save
    I18n.locale = 'en-US'
    section = Section.first
    assert_equal 'foo', section.content 
    I18n.locale = 'de-DE'
    assert_equal 'bar', section.content 
  end

  test "returns the value for the correct locale, after locale switching, without saving" do
    section = Section.create :content => 'foo'
    I18n.locale = 'de-DE'
    section.content = 'bar'
    I18n.locale = 'en-US'
    assert_equal 'foo', section.content 
    I18n.locale = 'de-DE'
    assert_equal 'bar', section.content 
  end

  test "saves all locales, even after locale switching" do
    section = Section.new :content => 'foo'
    I18n.locale = 'de-DE'
    section.content = 'bar'
    I18n.locale = 'he-IL'
    section.content = 'baz'
    section.save
    I18n.locale = 'en-US'
    section = Section.first
    assert_equal 'foo', section.content 
    I18n.locale = 'de-DE'
    assert_equal 'bar', section.content 
    I18n.locale = 'he-IL'
    assert_equal 'baz', section.content 
  end

  test "resolves a simple fallback" do
    I18n.locale = 'de-DE'
    section = Section.create :content => 'foo'
    I18n.locale = 'de'
    section.content = 'baz'
    section.save
    I18n.locale = 'de-DE'
    assert_equal 'foo', section.content 
  end

  test "resolves a simple fallback without reloading" do
    I18n.locale = 'de-DE'
    section = Section.new :content => 'foo'
    I18n.locale = 'de'
    section.content = 'baz'
    I18n.locale = 'de-DE'
    assert_equal 'foo', section.content 
  end

  test "resolves a complex fallback without reloading" do
    I18n.fallbacks.map 'de' => %w(en he)
    I18n.locale = 'de'
    section = Section.new
    I18n.locale = 'en'
    section.content = 'foo'
    I18n.locale = 'he'
    section.content = 'baz'
    I18n.locale = 'de'
    assert_equal 'foo', section.content 
  end

  test "returns nil if no translations are found" do
    section = Section.new :content => 'foo'
    assert_equal 'foo', section.content
  end

  test "returns nil if no translations are found; reloaded" do
    section = Section.create :content => 'foo'
    section = Section.first
    assert_equal 'foo', section.content
  end
  
  test "works with simple dynamic finders" do
    foo = Section.create :content => 'foo'
    Section.create :content => 'bar'
    section = Section.find_by_content('foo')
    assert_equal foo, section
  end

end