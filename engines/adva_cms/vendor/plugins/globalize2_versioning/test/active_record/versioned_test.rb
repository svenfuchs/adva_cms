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

class VersionedTest < ActiveSupport::TestCase
  def setup
    I18n.locale = :'en-US'
    I18n.fallbacks.clear 
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'schema.rb'))
  end
  
  ########################################
  # Test translated field only for Section
  ########################################

  test "modifiying translated fields" do
    section = Section.create :title => 'foo'
    assert_equal 'foo', section.title
    section.title = 'bar'
    assert_equal 'bar', section.title    
  end

  test "modifiying translated fields while switching locales" do
    section = Section.create :title => 'foo'
    assert_equal 'foo', section.title
    I18n.locale = :'de-DE'
    section.title = 'bar'
    assert_equal 'bar', section.title
    I18n.locale = :'en-US'
    assert_equal 'foo', section.title
    I18n.locale = :'de-DE'
    section.title = 'bar'
  end
  
  test "has section_translations" do
    section = Section.create
    assert_nothing_raised { section.globalize_translations }
  end

  test "returns the value passed to :title" do
    section = Section.new
    assert_equal 'foo', (section.title = 'foo')
  end

  test "translates subject and content into en-US" do
    section = Section.create :title => 'foo', :content => 'bar'
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
    assert section.save
    section.reload
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
  end

  test "finds a German section" do
    I18n.fallbacks.map 'de-DE' => [ 'en-US' ]
    section = Section.create :title => 'foo (en)', :content => 'bar'
    I18n.locale = 'de-DE'
    section = Section.first
    section.title = 'baz (de)'
    assert section.save
    assert_equal 'baz (de)', Section.first.title 
    I18n.locale = :'en-US'
    assert_equal 'foo (en)', Section.first.title 
  end

  test "saves an English section and loads test correctly" do
    assert_nil Section.first
    section = Section.create :title => 'foo', :content => 'bar'
    assert section.save
    section = Section.first
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
  end

  test "updates an attribute" do
    section = Section.create :title => 'foo', :content => 'bar'
    section.update_attribute :title, 'baz'
    section = Section.first
    assert_equal 'baz', Section.first.title 
  end

  test "updates an attribute with fallback" do
    I18n.fallbacks.map :de => [ :'en-US' ]
    section = Section.create :title => 'foo', :content => 'bar'
    section.update_attribute :title, 'baz'
    assert_equal 'baz', section.title

    I18n.locale = :de
    assert_equal 'baz', section.title

    I18n.locale = :'en-US'
    
    section = Section.first
    assert_equal 'baz', section.title
    
    I18n.locale = :de
    assert_equal 'baz', section.title
    assert_equal 'baz', Section.first.title
  end

  test "validates presence of :content" do
    section = Section.new
    assert !section.save

    section = Section.new :content => 'foo'
    assert section.save
  end

  test "returns the value for the correct locale, after locale switching" do
    section = Section.create :title => 'foo', :content => 'bar'
    I18n.locale = 'de-DE'
    section.title = 'bar'
    section.save
    I18n.locale = 'en-US'
    section = Section.first
    assert_equal 'foo', section.title 
    I18n.locale = 'de-DE'
    assert_equal 'bar', section.title 
  end

  test "returns the value for the correct locale, after locale switching, without saving" do
    section = Section.create :title => 'foo'
    I18n.locale = 'de-DE'
    section.title = 'bar'
    I18n.locale = 'en-US'
    assert_equal 'foo', section.title 
    I18n.locale = 'de-DE'
    assert_equal 'bar', section.title 
  end

  test "saves all locales, even after locale switching" do
    section = Section.new :content => 'foo'
    I18n.locale = 'de-DE'
    section.content = 'bar'
    I18n.locale = 'he-IL'
    section.content = 'baz'
    assert section.save
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
    section = Section.create :title => 'foo', :content => 'bar'
    I18n.locale = 'de'
    section.title = 'baz'
    section.content = 'bar'
    section.save
    I18n.locale = 'de-DE'
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
  end

  test "resolves a simple fallback without reloading" do
    I18n.locale = 'de-DE'
    section = Section.new :title => 'foo'
    I18n.locale = 'de'
    section.title = 'baz'
    section.content = 'bar'
    I18n.locale = 'de-DE'
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
  end

  test "resolves a complex fallback without reloading" do
    I18n.fallbacks.map 'de' => %w(en he)
    I18n.locale = 'de'
    section = Section.new
    I18n.locale = 'en'
    section.title = 'foo'
    I18n.locale = 'he'
    section.title = 'baz'
    section.content = 'bar'
    I18n.locale = 'de'
    assert_equal 'foo', section.title 
    assert_equal 'bar', section.content 
  end

  test "returns nil if no translations are found" do
    section = Section.new :title => 'foo'
    assert_equal 'foo', section.title
    assert_nil section.content
  end

  test "returns nil if no translations are found; reloaded" do
    section = Section.create :content => 'foo'
    section = Section.first
    assert_equal 'foo', section.content
    assert_nil section.title
  end
  
  test "works with simple dynamic finders" do
    foo = Section.create :title => 'foo', :content => 'bar'
    Section.create :title => 'bar'
    section = Section.find_by_title('foo')
    assert_equal foo, section
  end
end
