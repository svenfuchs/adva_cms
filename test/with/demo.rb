require File.dirname(__FILE__) + '/test/helper'

require 'rubygems'
require 'actionpack'
require 'action_controller'
require 'action_controller/test_process'
require 'active_support'

# setup some fakes so the demo can run

class Article
  attr_reader :errors

  def initialize(attributes)
    @attributes = attributes
  end

  def save
    @errors = ['title', 'body'] - @attributes.keys
    @errors.empty?
  end
end

class User
  def initialize(admin = false)
    @admin = admin
  end

  def admin?
    @admin
  end
end

class ArticlesController < ActionController::Base
  attr_accessor :current_user
  before_filter :require_admin

  def create
    @article = Article.new params
    if @article.save
      redirect_to '/articles/1'
    else
      flash[:error] = "missing: #{@article.errors.join(', ')}"
      render :text => "can't fake a real template easily?"
    end
  end

  protected

    def require_admin
      redirect_to '/login' unless current_user && current_user.admin?
    end
end

ActionController::Routing.module_eval do
  set = ActionController::Routing::RouteSet.new
  set.draw {|map| map.articles 'articles', :controller => 'articles', :action => 'create'}
  remove_const :Routes
  const_set :Routes, set
end

# share some contexts and set up some macros

class ActionController::TestCase
  include With

  share :login_as_admin do
    before { @controller.current_user = User.new(true) }
  end

  share :login_as_user do
    before { @controller.current_user = User.new(false) }
  end

  share :no_login do
    before { @controller.current_user = nil }
  end

  share :valid_article_params do
    before { @params = valid_article_params }
  end

  share :invalid_article_params, 'missing title' do
    before { @params = valid_article_params.except(:title) }
  end

  share :invalid_article_params, 'missing body' do
    before { @params = valid_article_params.except(:body) }
  end
  
  share :caching do
    before { @caching = true }
  end
  
  share :observers do
    before { @observers = true }
  end

  def it_redirects_to(path = nil, &block)
    path = instance_eval(&block) if block
    assert_redirected_to path
  end

  def it_assigns(name)
    assert_not_nil @controller.instance_variable_get(:"@#{name}")
  end

  def it_assigns_flash(key, pattern)
    assert flash[:error] =~ pattern
  end

  def valid_article_params
    { :title => 'an article title', :body => 'an article body' }
  end
end

# and now the fun starts ...

class ArticlesControllerTest < ActionController::TestCase
  with_common :caching, :observers
  
  describe 'POST to :create' do
    before do
      # set up some preconditions
      @before_block_called = true
    end

    action { post :create, @params }

    it "has called the before blocks" do
      assert @caching
      assert @observers
      assert @before_block_called
    end

    with :login_as_admin do
      it_assigns :article

      it "succeeds", :with => :valid_article_params do
        it_redirects_to { 'articles/1' }

        it "can nest assertions" do
          assert true
        end
      end

      it "fails", :with => :invalid_article_params do
        it_assigns_flash :error, /missing: (body|title)/
      end
    end

    with [:login_as_user, :no_login] do
      it_redirects_to { '/login' }
    end
  end

  puts "tests defined: \n  " + instance_methods.grep(/^test_/).join(", \n  ")
end