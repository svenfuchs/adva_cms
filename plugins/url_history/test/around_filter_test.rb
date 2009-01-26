require File.dirname(__FILE__) + '/test_helper.rb'

class UrlHistoryAroundFilterTest < ActionController::TestCase
  include UrlHistory
  tests TestController

  def setup
    Article.delete_all
    Entry.delete_all

    @article = Article.create!(:permalink => 'the-permalink')
    @controller.instance_variable_set(:@article, @article)

    TestController.tracks_url_history(:foo => :bar)
    ActionController::Routing::Routes.draw { |map| map.connect ':controller/:action/:permalink' }
  end

  test "gets called" do
    AroundFilter.expects(:after)
    get :show, :permalink => @article.permalink
  end

  test "saves the current url to the urls table if it's not already there" do
    get :show, :permalink => @article.permalink
    assert_equal 1, Entry.count

    entry = Entry.first
    assert entry.url == @controller.request.url
    assert entry.resource.is_a?(Article)
  end

  test "does not write anything when an entry already exists" do
    get :show, :permalink => @article.permalink
    entries = Entry.all
    get :show, :permalink => @article.permalink
    assert_equal 1, Entry.count
    assert_equal entries.first, Entry.first
  end
end
