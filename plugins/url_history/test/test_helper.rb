$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'active_record'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_process'

require 'mocha'
require File.dirname(__FILE__) + '/db/connect'

require 'url_history'

class Content < ActiveRecord::Base
end

class Article < Content
  def full_permalink
    { :year => '2008', :month => '1', :day => '1', :permalink => permalink }
  end
  
  def update_url_history_params(params)
    params.has_key?(:year) ? params.merge(full_permalink) : params
  end
end

class Wikipage < Content
end

class TestController < ActionController::Base
  include UrlHistory::Tracking
  
  def show
    Article.find_by_permalink(params[:permalink]) || raise(ActiveRecord::RecordNotFound)
    render :text => 'show'
  end
  
  def current_resource
    @article
  end
end
