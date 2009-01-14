$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'actionpack'
require 'action_controller'
require 'mocha'

require 'page_cache_tagging'
require 'page_cache_tagging/attributes_read_observer'
require 'page_cache_tagging/method_read_observer'
require 'page_cache_tagging/read_access_tracker'

class ArticlesController < ActionController::Base
  caches_page_with_references :show, :track => [:@article, { :@article => :section }]
  
  def params
    { :action => :show }
  end
  
  def render_without_read_access_tracking
  end
end

class Article
  def initialize
    @attributes = {:title => '', :body => ''}
  end
  
  def section ; end

  def [](key) 
    @attributes[key]
  end
  
  def has_attribute?(name)
    @attributes.keys.include? name
  end
end

class PageCacheTaggingTest < Test::Unit::TestCase
  def setup
    @article = Article.new

    @controller = ArticlesController.new
    @controller.stubs(:save_tracked_cache_references)
    @controller.instance_variable_set(:@article, @article)
    @controller.send :render
    
    @tracker = @controller.instance_variable_get(:@read_access_tracker)
  end
  
  def test_access_to_an_attribute_on_an_observed_object_records_the_reference
    @article[:title]
    assert @tracker.references.include?([@article, nil])
  end
  
  def test_access_to_a_registered_method_on_an_observed_object_records_the_reference
    @article.section
    assert @tracker.references.include?([@article, :section])
  end
end