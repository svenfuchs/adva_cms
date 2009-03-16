$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'action_controller'
require 'active_record'
require 'active_support'
require 'active_support/test_case'
require 'mocha'
require 'has_filter'

class Test::Unit::TestCase
  include ActionController::Assertions::SelectorAssertions

  def assert_html(html, *args, &block)
    assert_select(HTML::Document.new(html).root, *args, &block)
  end
end

require File.dirname(__FILE__) + '/db/connect'
module HasFilter
  class Article < ActiveRecord::Base
    set_table_name 'has_filter_articles'
    has_filter :title, :body, :tags, :published

    named_scope :published, :conditions => 'published = 1'
    named_scope :approved, :conditions => 'approved = 1'
  end

  Article.delete_all
  Article.create! :title => 'first',  :body => 'first',  :published => 1, :approved => 0, :tag_list => 'foo bar baz'
  Article.create! :title => 'second', :body => 'second', :published => 1, :approved => 1, :tag_list => 'foo bar'
  Article.create! :title => 'third',  :body => 'third',  :published => 0, :approved => 0, :tag_list => 'foo'
  
  class Person < ActiveRecord::Base
    set_table_name 'has_filter_people'
    has_filter :first_name, :last_name
  end

  Person.delete_all
  Person.create! :first_name => 'John', :last_name => 'Doe'
  Person.create! :first_name => 'Jane', :last_name => 'Doe'
  Person.create! :first_name => 'Rick', :last_name => 'Roe'
  
  module TestHelper
    def filter_chain
      chain = Filter::Chain.new
      chain << text_filter << tags_filter << state_filter
      chain
    end

    def text_filter
      Filter::Text.new(:body)
    end

    def tags_filter
      Filter::Tags.new
    end

    def state_filter
      Filter::State.new(:state, :states => [:published, :unpublished])
    end
  end
end