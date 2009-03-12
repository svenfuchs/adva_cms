require File.dirname(__FILE__) + '/../test_helper.rb'

class UrlHistoryExceptionHandlerTest < ActionController::TestCase
  tests TestController
  include ActionController::Routing
  include UrlHistory

  def setup
    super
    TestController.tracks_url_history
    Routes.draw do |map| 
      map.connect 'sections/:section_id/articles/:year/:month/:day/:permalink',
                  :controller => 'test', :action => "show"
    end
    @path = '/sections/1/articles/2008/1/1/a-blog-article'
    Entry.delete_all
  end
  
  test "recognizes the path" do
    params = { :controller => "test", :action => "show",  :section_id => "1", 
               :year => '2008', :month => '1', :day => '1', :permalink => "a-blog-article" }
    assert_equal params, Routes.recognize_path(@path)
  end
  
  # test "handler_for_rescue_except_url_history returns previously registered exception handlers" do
  #   with_default_rescue_from_handler do
  #     exception = ActiveRecord::RecordNotFound.new
  #     handler = @controller.send :handler_for_rescue_except_url_history, exception
  #     assert handler
  #     assert_equal 'default_record_not_found', handler.name
  #   end
  # end
  
  test "catches the exception, looks up an entry and redirects to its new url" do
    article = Blog.first.articles.first
    @controller.instance_variable_set(:@article, article)
    existing_url_params = article.full_permalink.merge(:section_id => "1")

    # request an existing article url
    get :show, existing_url_params

    # now we have an entry in the history
    assert entry = Entry.recent_by_url("http://test.host#{@path}")
  
    # the article permalink is updated
    article.update_attributes! :permalink => 'the-new-permalink'

    # this will now raise a RecordNotFound exception
    get :show, existing_url_params

    # and we're redirected to the new article url
    assert_redirected_to 'http://test.host/sections/1/articles/2008/1/1/the-new-permalink'
    assert_response 302
  end
  
  # test "raises ActiveRecord::RecordNotFound if no entry can be found (no other handler defined)" do
  #   # the history is empty
  #   assert_equal 0, Entry.count
  #   
  #   # this will now raise an unhandled RecordNotFound exception
  #   assert_raises ActiveRecord::RecordNotFound do
  #     get :show, :section_id => "1", :permalink => "the-permalink", :year => '2008', :month => '1', :day => '1'
  #   end
  # end
  # 
  # test "calls previously registered handlers if no entry can be found (other handler defined)" do
  #   # the history is empty
  #   assert_equal 0, Entry.count
  # 
  #   with_default_rescue_from_handler do
  #     # this will now call the previously registered handler
  #     @controller.expects(:default_record_not_found)
  #     get :show, :section_id => "1", :permalink => "the-permalink", :year => '2008', :month => '1', :day => '1'
  #   end
  # end
  # 
  # def with_default_rescue_from_handler
  #   # fudge a previously registered exception handler
  #   TestController.rescue_handlers.unshift ["ActiveRecord::RecordNotFound", :default_record_not_found]
  #   yield
  #   TestController.rescue_handlers.shift
  # end
end