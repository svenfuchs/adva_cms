require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class TrackerTest < ActiveSupport::TestCase
  def setup
    super
    @tracker = Tracker.new
  end
  
  test "associations" do
    @tracker.should have_many(:projects)
  end
end
