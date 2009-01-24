require File.dirname(__FILE__) + '/../../../test_helper'

class SpamEngineFilterTest < ActiveSupport::TestCase
  test "returns the registered filter names" do
    SpamEngine::Filter.names.should == ['Default', 'Akismet', 'Defensio']
  end
end