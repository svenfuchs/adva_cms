$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'actionpack'
require 'action_controller'
require 'mocha'

require 'cache_references/page_caching'

class ArticlesController < ActionController::Base
  caches_page_with_references :show, :track => [:@article, :@comments, { :@article => :section, :@comments => :section }]
  
  def params
    { :action => :show }
  end
  
  def render_without_cache_reference_tracking(*args)
  end
end

class Record
  include CacheReferences::MethodCallTracking
  
  def section
  end

  def read_attribute(name)
    @attributes[name]
  end
  
  def method_missing(name)
    read_attribute(name)
  end
end

class Article < Record
  def initialize
    @attributes = {:title => '', :body => ''}
  end
end

class Comment < Record
  def initialize
    @attributes = {:body => ''}
  end
end

