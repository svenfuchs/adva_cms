require File.dirname(__FILE__) + '/test_helper.rb'

class UrlHistoryExceptionHandlerTest < ActionController::TestCase
  tests TestController
  include ActionController::Routing
  include UrlHistory

  def setup
    super
    
    Routes.draw do |map| 
      map.connect 'sections/:section_id/articles/:year/:month/:day/:permalink',
                  :controller => 'test', :action => "show"
    end

    TestController.tracks_url_history
    Entry.delete_all
    Article.delete_all
    
    @path = '/sections/1/articles/2008/1/1/the-permalink'
  end
  
  test "recognizes the path" do
    params = { :controller => "test", :action => "show",  :section_id => "1", 
               :year => '2008', :month => '1', :day => '1', :permalink => "the-permalink" }
    assert_equal params, Routes.recognize_path(@path)
  end
  
  test "semi-integration" do
    article = Article.create!(:permalink => 'the-permalink')
    @controller.instance_variable_set(:@article, article)
    
    # request an existing article url
    get :show, :section_id => "1", :permalink => "the-permalink", :year => '2008', :month => '1', :day => '1'
    # now we have an entry in the history

    assert entry = Entry.recent_by_url("http://test.host#{@path}")

    # the article permalink is updated
    article.update_attributes! :permalink => 'the-new-permalink'
    # path = @controller.url_for(entry.updated_params.merge :only_path => true)
    # assert_equal '/sections/1/articles/the-new-permalink', path

    # this will now raise a RecordNotFound exception
    get :show, :section_id => "1", :permalink => "the-permalink", :year => '2008', :month => '1', :day => '1'
    # and we're redirected to the new article url
    assert_redirected_to 'http://test.host/sections/1/articles/2008/1/1/the-new-permalink'
    assert_response 302
  end
end