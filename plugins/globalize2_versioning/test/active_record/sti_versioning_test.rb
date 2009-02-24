# This test suite tests versioning with Single Table Inheritance

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

class StiVersioningTest < ActiveSupport::TestCase
  def setup
    I18n.fallbacks.clear 
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'schema.rb'))
    I18n.locale = :en
  end
  
  test 'versioned? method' do
    post = Post.new
    assert !post.versioned?
    wiki = Wiki.new
    assert wiki.versioned?
  end
  
  test 'new record version' do
    wiki = Wiki.create :article => 'foo'
    assert_equal 1, wiki.version
  end
    
  test 'subsequent version' do
    wiki = Wiki.create :article => 'foo'
    assert_equal 1, wiki.version
    wiki.article = 'bar'
    assert wiki.save
    assert_equal 2, wiki.version
    wiki.update_attribute(:article, 'baz')    
    assert_equal 3, wiki.version
  end
  
  test 'current version' do
    wiki = Wiki.create :article => 'foo'
    assert_equal 1, wiki.version
    wiki.article = 'bar'
    assert wiki.save
    assert_equal 2, wiki.version
    wiki.update_attribute(:article, 'baz')    
    assert_equal 3, wiki.version
    wiki.reload
    assert_equal 3, wiki.version
    assert_equal 'baz', wiki.article
  end
  
  test 'current version with locale switching' do
    I18n.locale = :de
    
    wiki = Wiki.create :article => 'foo (de)'
    assert_equal 1, wiki.globalize_translations.size
    
    wiki.update_attribute :article, 'bar (de)'    
    assert_equal 2, wiki.globalize_translations.size

    assert_equal 2, wiki.version
    assert_equal 'bar (de)', wiki.article

    I18n.locale = :en
    wiki.update_attribute :article, 'foo'
    assert_equal 1, wiki.version
    wiki.update_attribute :article, 'bar'
    assert_equal 2, wiki.version
    wiki.update_attribute(:article, 'baz')    
    assert_equal 3, wiki.version
    wiki.reload
    assert_equal 3, wiki.version

    I18n.locale = :de    
    assert_equal 2, wiki.version
    assert_equal 'bar (de)', wiki.article
  end

  test 'save_version? on new record' do
    wiki = Wiki.new :article => 'foo'
    assert wiki.save_version?
  end

  test 'save_version_on_create' do
    wiki = Wiki.create :article => 'foo'
    assert !wiki.save_version?
  end

  test 'save_version?' do
    wiki = Wiki.create :article => 'foo'
    assert !wiki.save_version?
    wiki.title = 'bar'
    assert !wiki.save_version?
    wiki.article = 'baz'
    assert wiki.save_version?
  end

  test 'revert_to' do
    wiki = Wiki.create :article => 'foo'
    wiki.update_attribute :article, 'bar'    
    wiki.update_attribute :article, 'baz'
    assert_equal 'baz', wiki.article
    assert_equal 3, wiki.version
    wiki.revert_to 1
    assert_equal 'foo', wiki.article
    assert_equal 1, wiki.version
    wiki.revert_to 2
    assert_equal 'bar', wiki.article
    assert_equal 2, wiki.version
    
    # load from db
    wiki = Wiki.first
    assert_equal 'bar', wiki.article
    assert_equal 2, wiki.version    
  end

  test 'versioned_attributes method' do
    assert_equal [ :article ], Wiki.versioned_attributes
  end
  
  test 'max_version_limit' do
    assert_equal 5, Wiki.max_version_limit
  end
  
  test 'version limit' do
    wiki = Wiki.create :article => 'foo1'
    wiki.update_attribute :article, 'foo2'
    wiki.update_attribute :article, 'foo3'
    wiki.update_attribute :article, 'foo4'
    wiki.update_attribute :article, 'foo5'
    assert_not_nil wiki.globalize_translations.find_by_locale_and_version(I18n.locale.to_s, 1)
    wiki.update_attribute :article, 'foo6'
    assert_nil wiki.globalize_translations.find_by_locale_and_version(I18n.locale.to_s, 1)
    assert_not_nil wiki.globalize_translations.find_by_locale_and_version(I18n.locale.to_s, 2)
    wiki.update_attribute :article, 'foo7'
    assert_nil wiki.globalize_translations.find_by_locale_and_version(I18n.locale.to_s, 2)
    assert_not_nil wiki.globalize_translations.find_by_locale_and_version(I18n.locale.to_s, 3)
  end  
  
end