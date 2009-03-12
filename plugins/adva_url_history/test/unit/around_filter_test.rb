require File.dirname(__FILE__) + '/../test_helper.rb'

class UrlHistoryAroundFilterTest < ActionController::TestCase
  include UrlHistory
  tests TestController

  def setup
    Entry.delete_all

    @article = Article.first
    @controller.instance_variable_set(:@article, @article)

    TestController.tracks_url_history
    ActionController::Routing::Routes.draw do |map| 
      map.connect ':controller/:action/:permalink' 
      map.connect ':controller/non_get', :action => 'non_get'
    end
  end

  test "gets called" do
    AroundFilter.expects(:after)
    get :show, :permalink => @article.permalink
  end

  test "on GET requests it saves the current url to the urls table if it's not already there" do
    get :show, :permalink => @article.permalink
    assert_equal 1, Entry.count

    entry = Entry.first
    assert entry.url == @controller.request.url
    assert entry.resource.is_a?(Article)
  end

  test "on GET requests it does not write anything when an entry already exists" do
    get :show, :permalink => @article.permalink
    entries = Entry.all
    get :show, :permalink => @article.permalink
    assert_equal 1, Entry.count
    assert_equal entries.first, Entry.first
  end
  
  test "on POST requests it does not do anything" do
    assert_no_difference('Entry.count') { post :non_get }
  end
  
  test "on PUT requests it does not do anything" do
    assert_no_difference('Entry.count') { put :non_get }
  end
  
  test "on DELETE requests it does not do anything" do
    assert_no_difference('Entry.count') { delete :non_get }
  end
end