# require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
# Rails.backtrace_cleaner.remove_silencers!

unless defined?(Rails)
  $: << File.expand_path(File.dirname(__FILE__) + '/../lib')

  require 'rubygems'
  require 'action_controller'
  require 'active_record'
  require 'active_support'
  require 'active_support/test_case'
  require 'action_view'
  require 'mocha'

  require 'has_filter'
  require 'has_filter/active_record/act_macro'
  ActiveRecord::Base.send :extend, HasFilter::ActiveRecord::ActMacro

  $: << File.expand_path(File.dirname(__FILE__) + '/../../simple_taggable/lib')
  require 'simple_taggable'
end

class Test::Unit::TestCase
  include ActionController::Assertions::SelectorAssertions

  def assert_html(html, *args, &block)
    assert_select(HTML::Document.new(html).root, *args, &block)
  end
end

require File.dirname(__FILE__) + '/db/setup'
require File.dirname(__FILE__) + '/models'
require File.dirname(__FILE__) + '/fixtures'

module HasFilter
  class TestController < ActionController::Base
    include HasFilter
    helper_method :filter_for
    def index
      prepend_view_path File.dirname(__FILE__) + '/templates'
    end
  end
  
  module TestHelper
    def text_filter
      Filter::Text.new(:attribute => :body)
    end

    def categorized_filter
      Filter::Categorized.new
    end

    def tagged_filter
      Filter::Tagged.new
    end

    def state_filter
      Filter::State.new(:state, :states => [:published, :unpublished])
    end
  end
end

ActionController::Routing::Routes.draw do |map| 
  map.connect 'has_filter', :controller => 'has_filter/test', :action => 'index'
end

