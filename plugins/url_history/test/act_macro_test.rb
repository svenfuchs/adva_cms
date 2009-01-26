require File.dirname(__FILE__) + '/test_helper.rb'

class UrlHistoryActMacroTest < ActiveSupport::TestCase
  setup do
    TestController.tracks_url_history(:foo => :bar)
  end
  
  test "tracks the url history" do
    assert TestController.tracks_url_history?
  end
  
  test "sets given options to :url_history_options" do
    assert_equal({:foo => :bar}, TestController.url_history_options)
  end
  
  test "registers the after_filter" do
    assert !!TestController.filter_chain.detect { |filter| filter.method == UrlHistory::AroundFilter }
  end
  
  test "does not install multiple times on repeated calls" do
    TestController.tracks_url_history(:foo2 => :bar2)
    assert_equal({:foo => :bar}, TestController.url_history_options)
  end
end
