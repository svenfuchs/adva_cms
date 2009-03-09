require 'test_helper'

class CalendarHelperTest < ActiveSupport::TestCase
  include LaterDude::CalendarHelper

  test "requires year and month" do
    assert_raises(ArgumentError) { calendar_for }
    assert_raises(ArgumentError) { calendar_for(2009) }
    assert_nothing_raised { calendar_for(2009, 1) }
  end

  test "accepts optional options hash" do
    options = { :calendar_class => "my_calendar", :first_day_of_week => 1 }
    assert_nothing_raised { calendar_for(2009, 1, options) }
  end

  test "accepts optional block" do
    options = { :calendar_class => "my_calendar", :first_day_of_week => 1 }
    some_block = lambda { nil }

    assert_nothing_raised { calendar_for(2009, 1, &some_block) }
    assert_nothing_raised { calendar_for(2009, 1, options, &some_block) }
  end
end
