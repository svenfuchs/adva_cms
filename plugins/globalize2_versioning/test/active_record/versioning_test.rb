# This test suite tests the actual versioning of versioned fields

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

class VersioningTest < ActiveSupport::TestCase
  def setup
    I18n.fallbacks.clear 
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'schema.rb'))
    ActiveRecord::Base.locale = :de
    ActiveRecord::Base.locale = :en
  end
  
  test 'versioned? method' do
    post = Post.new
    assert !post.versioned?
    section = Section.new
    assert section.versioned?
  end
  
  test 'new record version' do
    section = Section.create :content => 'foo'
    assert_equal 1, section.version
  end
    
  test 'subsequent version' do
    section = Section.create :content => 'foo'
    assert_equal 1, section.version
    section.content = 'bar'
    assert section.save
    assert_equal 2, section.version
    section.update_attribute(:content, 'baz')    
    assert_equal 3, section.version
  end
  
  test 'current version' do
    section = Section.create :content => 'foo'
    assert_equal 1, section.version
    section.content = 'bar'
    assert section.save
    assert_equal 2, section.version
    section.update_attribute(:content, 'baz')    
    assert_equal 3, section.version
    section.reload
    assert_equal 3, section.version
    assert_equal 'baz', section.content
  end
  
  test 'current version with locale switching' do
    ActiveRecord::Base.locale = :de
    
    section = Section.create :content => 'foo (de)'
    assert_equal 1, section.globalize_translations.size
    
    section.update_attribute :content, 'bar (de)'    
    assert_equal 2, section.globalize_translations.size

    assert_equal 2, section.version
    assert_equal 'bar (de)', section.content

    ActiveRecord::Base.locale = :en
    section.update_attribute :content, 'foo'
    assert_equal 1, section.version
    section.update_attribute :content, 'bar'
    assert_equal 2, section.version
    section.update_attribute(:content, 'baz')    
    assert_equal 3, section.version
    section.reload
    assert_equal 3, section.version

    ActiveRecord::Base.locale = :de    
    assert_equal 2, section.version
    assert_equal 'bar (de)', section.content
  end
  
  test 'current version with fallbacks' do
    I18n.fallbacks.map :de => [ :en ]
    section = Section.create :content => 'foo'
    
    ActiveRecord::Base.locale = :de
    assert_equal 'foo', section.content
    assert_nil section.version
    
    ActiveRecord::Base.locale = :en
    section.update_attribute :content, 'bar'
    
    ActiveRecord::Base.locale = :de
    assert_equal 'bar', section.content
    
    # no translation record for :de, so version is nil
    assert_nil section.version

    # load from db
    section = Section.first
    assert_equal 'bar', section.content
    assert_nil section.version

    # load from db, then switch locale
    ActiveRecord::Base.locale = :en
    section = Section.first
    ActiveRecord::Base.locale = :de
    assert_equal 'bar', section.content
    assert_nil section.version
  end
  
  test 'current current version with fallbacks -- current language has record' do
    I18n.fallbacks.map :de => [ :en ]
    section = Section.create :content => 'foo'
    
    ActiveRecord::Base.locale = :de
    assert_equal 'foo', section.content
    assert_nil section.version
    
    ActiveRecord::Base.locale = :en
    section.update_attribute :content, 'bar'
    
    ActiveRecord::Base.locale = :de
    section.update_attribute :content, 'bar (de)'
    assert_equal 1, section.version

    # load from db
    section = Section.first
    assert_equal 'bar (de)', section.content
    assert_equal 1, section.version

    section.update_attribute :content, 'baz (de)'
    assert_equal 'baz (de)', section.content
    assert_equal 2, section.version

    # load from db
    section = Section.first
    assert_equal 'baz (de)', section.content
    assert_equal 2, section.version

    # load from db, then switch locale
    ActiveRecord::Base.locale = :en
    section = Section.first
    ActiveRecord::Base.locale = :de
    assert_equal 'baz (de)', section.content
    assert_equal 2, section.version
    
    # continue versioning in :en
    ActiveRecord::Base.locale = :en
    assert_equal 'bar', section.content
    assert_equal 2, section.version
    section.update_attribute :content, 'baz'
    assert_equal 'baz', section.content
    assert_equal 3, section.version
    
    # load from db
    section = Section.first
    assert_equal 'baz', section.content
    assert_equal 3, section.version    
  end
  
  test 'save_version? on new record' do
    section = Section.new :content => 'foo'
    assert section.save_version?
  end

  test 'save_version_on_create' do
    section = Section.create :content => 'foo'
    assert !section.save_version?
  end

  test 'save_version?' do
    section = Section.create :content => 'foo'
    assert !section.save_version?
    section.title = 'bar'
    assert !section.save_version?
    section.content = 'baz'
    assert section.save_version?
  end

  test 'revert_to' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    section.update_attribute :content, 'baz'
    assert_equal 'baz', section.content
    assert_equal 3, section.version
    section.revert_to 1
    assert_equal 'foo', section.content
    assert_equal 1, section.version
    section.revert_to 2
    assert_equal 'bar', section.content
    assert_equal 2, section.version
    
    # load from db
    section = Section.first
    assert_equal 'bar', section.content
    assert_equal 2, section.version    
  end

  test 'revert_to failure' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    assert !section.revert_to(3)
  end
  
  test 'revert_to same version' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    assert section.revert_to(2)
    assert_equal 'bar', section.content
    assert_equal 2, section.version
  end

  test 'revert_to same version (version is string)' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    assert section.revert_to('2')
    assert_equal 'bar', section.content
    assert_equal 2, section.version
  end
  
  test 'revert_to with callbacks' do
    I18n.fallbacks.map :de => [ :en ]
  
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    section.update_attribute :content, 'baz'
    assert_equal 'baz', section.content
    assert_equal 3, section.version

    # :de
    ActiveRecord::Base.locale = :de
    section.update_attribute :content, 'baz (de)'
    section.update_attribute :content, 'qux (de)'
    assert_equal 2, section.version
    
    ActiveRecord::Base.locale = :en
    section.revert_to 1
    assert_equal 'foo', section.content
    assert_equal 1, section.version

    ActiveRecord::Base.locale = :de
    assert_equal 2, section.version
    assert_equal 'qux (de)', section.content
    ActiveRecord::Base.locale = :en
    
    section.revert_to 2
    assert_equal 'bar', section.content
    assert_equal 2, section.version
    
    # load from db
    section = Section.first
    assert_equal 'bar', section.content
    assert_equal 2, section.version    

    ActiveRecord::Base.locale = :de
    assert_equal 2, section.version
    assert_equal 'qux (de)', section.content
    
    section.revert_to 1
    assert_equal 1, section.version
    assert_equal 'baz (de)', section.content

    ActiveRecord::Base.locale = :en
    assert_equal 'bar', section.content
    assert_equal 2, section.version    
    ActiveRecord::Base.locale = :de

    section = Section.first
    assert_equal 1, section.version
    assert_equal 'baz (de)', section.content

    ActiveRecord::Base.locale = :en
    assert_equal 'bar', section.content
    assert_equal 2, section.version    
    ActiveRecord::Base.locale = :de      
  end
  
  test 'revert_to and then saving another version' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'    
    section.update_attribute :content, 'baz'
    section.revert_to 2

    section.update_attribute :content, 'qux'
    assert_equal 'qux', section.content
    assert_equal 4, section.version
        
    # load from db
    section = Section.first
    assert_equal 'qux', section.content
    assert_equal 4, section.version    

    section.revert_to 3

    assert_equal 'baz', section.content
    assert_equal 3, section.version
        
    # load from db
    section = Section.first
    assert_equal 'baz', section.content
    assert_equal 3, section.version      
  end
  
  test 'versioned_attributes method' do
    assert_equal [ :content ], Section.versioned_attributes
  end
  
  test 'max_version_limit' do
    assert_equal 5, Section.max_version_limit
  end
  
  test 'version limit' do
    section = Section.create :content => 'foo1'
    assert !section.versions.empty?
    section.update_attribute :content, 'foo2'
    section.update_attribute :content, 'foo3'
    section.update_attribute :content, 'foo4'
    section.update_attribute :content, 'foo5'
    assert_not_nil section.globalize_translations.find_by_locale_and_version(ActiveRecord::Base.locale.to_s, 1)
    section.update_attribute :content, 'foo6'
    assert_nil section.globalize_translations.find_by_locale_and_version(ActiveRecord::Base.locale.to_s, 1)
    assert_not_nil section.globalize_translations.find_by_locale_and_version(ActiveRecord::Base.locale.to_s, 2)
    section.update_attribute :content, 'foo7'
    assert_nil section.globalize_translations.find_by_locale_and_version(ActiveRecord::Base.locale.to_s, 2)
    assert_not_nil section.globalize_translations.find_by_locale_and_version(ActiveRecord::Base.locale.to_s, 3)
  end
  
  test 'empty versions' do
    section = Section.new
    assert section.versions.empty?
  end
  
  test 'version count' do
    section = Section.create :content => 'foo1'
    assert_equal 1, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 1, section.versions.last
    
    section.update_attribute :content, 'foo2'
    assert_equal 2, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 2, section.versions.last
    
    section.update_attribute :content, 'foo3'
    assert_equal 3, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 3, section.versions.last

    section.update_attribute :content, 'foo4'
    assert_equal 4, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 4, section.versions.last

    section.revert_to 2
    assert_equal 4, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 4, section.versions.last

    section.update_attribute :content, 'foo5'
    assert_equal 5, section.versions.count
    assert_equal 1, section.versions.first
    assert_equal 5, section.versions.last

    section.update_attribute :content, 'foo6'
    assert_equal 5, section.versions.count
    assert_equal 2, section.versions.first
    assert_equal 6, section.versions.last
  end
  
  test 'versions second and third' do
    section = Section.create :content => 'foo1'
    assert_nil section.versions.second
    assert_nil section.versions.third
    
    section.update_attribute :content, 'foo2'
    assert_equal 2, section.versions.second
    assert_nil section.versions.third
    
    section.update_attribute :content, 'foo3'
    assert_equal 2, section.versions.second
    assert_equal 3, section.versions.third

    section.update_attribute :content, 'foo4'
    assert_equal 2, section.versions.second
    assert_equal 3, section.versions.third

    section.revert_to 2
    assert_equal 2, section.versions.second
    assert_equal 3, section.versions.third

    section.update_attribute :content, 'foo5'
    assert_equal 2, section.versions.second
    assert_equal 3, section.versions.third

    section.update_attribute :content, 'foo6'
    assert_equal 3, section.versions.second
    assert_equal 4, section.versions.third
  end
    
  test 'versions[]' do
    section = Section.create :content => 'foo1'
    assert_equal 'foo1', section.versions[1].content
    assert section.versions[1].readonly?
    assert_nil section.versions[2]
    assert_nil section.versions[0]
    
    section.update_attribute :content, 'foo2'
    assert_equal 'foo1', section.versions[1].content
    assert_equal 'foo2', section.versions[2].content
    
    section.update_attribute :content, 'foo3'
    section.update_attribute :content, 'foo4'
    section.revert_to 2
    assert_equal 'foo3', section.versions[3].content
    assert_equal 'foo4', section.versions[4].content

    section.update_attribute :content, 'foo5'
    assert_equal 'foo5', section.versions[5].content
    assert_equal 'foo1', section.versions[1].content

    section.update_attribute :content, 'foo6'
    assert_equal 'foo6', section.versions[6].content
    assert_nil section.versions[1]
  end

  test 'save_without_revision' do
    section = Section.create :content => 'foo'
    assert 1, section.version
    section.content = 'bar'
    assert section.save_without_revision
    assert_equal 1, section.version
    assert_equal 'bar', section.content
    
    # reload from db
    section = Section.first
    assert_equal 1, section.version
    assert_equal 'bar', section.content

    assert_equal 1, section.versions.count
  end
  
  test 'if_changed argument' do
    product = Product.create :title => 'foo', :content => 'bar'
    assert_equal 1, product.version
    product.update_attribute :title, 'baz'
    assert_equal 'baz', product.title
    assert_equal 1, product.version
    product.update_attribute :content, 'qux'
    assert_equal 'baz', product.title
    assert_equal 'qux', product.content
    assert_equal 2, product.version
    product = Product.first
    assert_equal 'baz', product.title
    assert_equal 'qux', product.content
    assert_equal 2, product.version
  end
  
  test 'no update if validation fails' do
    section = Section.create :content => 'foo'
    assert_equal 'foo', section.content
    section.content = ''
    assert !section.save
    assert_equal 'foo', section.reload.content
  end
  
  test 'update_attributes' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'
    assert section.update_attributes( {} )    
    section.revert_to 1
    assert section.update_attributes( {} )    
  end

  test 'update_attributes failure' do
    section = Section.create :content => 'foo'
    assert !section.update_attributes( { :content => '' } )    
    assert_nil section.reload.attributes['content']
    assert_equal 'foo', section.content
  end

end