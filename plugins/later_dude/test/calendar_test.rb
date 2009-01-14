require 'test_helper'

# TODO: figure out why I have to reference Calendar via its module ...
class CalendarTest < ActiveSupport::TestCase
  # some constants for increased readability
  FULL_DAY_NAMES   = I18n.translate(:'date.day_names')
  ABBR_DAY_NAMES   = I18n.translate(:'date.abbr_day_names')
  FULL_MONTH_NAMES = I18n.translate(:'date.month_names')
  ABBR_MONTH_NAMES = I18n.translate(:'date.abbr_month_names')

  test "has default options" do
    # TODO improve this so that every call gets a fresh copy of the default options
    default_calendar_options = LaterDude::Calendar.send(:default_calendar_options)

    assert_kind_of Hash, default_calendar_options

    assert_equal "calendar", default_calendar_options[:calendar_class]

    [:hide_day_names, :hide_month_name, :use_full_day_names].each do |key|
      assert !default_calendar_options[key]
    end

    assert default_calendar_options[:use_full_month_names]

    # some options use i18n ...
    I18n.stubs(:translate).with(:'date.first_day_of_week', :default => "0").then.returns("1")
    I18n.stubs(:translate).with(:'date.formats.calendar_header', :default => "%B").then.returns("%B %Y")

    # default first day of week is Sunday (= 0) if no translation is set in locale
    assert_equal 0, default_calendar_options[:first_day_of_week]
    # with default first day of week set in locale
    assert_equal 1, (LaterDude::Calendar.send(:default_calendar_options)[:first_day_of_week]) # have to do this so that we don't use the cached version

    # default date format for header is to show the full month name if no translation is set in locale
    assert_equal "%B", default_calendar_options[:header_date_format]
    # with default date format set in locale
    assert_equal "%B %Y", (LaterDude::Calendar.send(:default_calendar_options)[:header_date_format])
  end

  # options
  test "uses full day names" do
    assert_equal FULL_DAY_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_day_names => true).send(:day_names)
  end

  test "uses abbreviated day names" do
    assert_equal ABBR_DAY_NAMES, LaterDude::Calendar.new(2009, 1).send(:day_names)
    assert_equal ABBR_DAY_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_day_names => false).send(:day_names)
  end

  test "uses full month names" do
    assert_equal FULL_MONTH_NAMES, LaterDude::Calendar.new(2009, 1).send(:month_names)
    assert_equal FULL_MONTH_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_month_names => true).send(:month_names)
  end

  test "uses abbreviated month names" do
    assert_equal ABBR_MONTH_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_month_names => false).send(:month_names)
  end

  test "doesn't show day names" do
    assert_nil LaterDude::Calendar.new(2009, 1, :hide_day_names => true).send(:show_day_names)
  end

  # TODO I think this isn't needed anymore due to the new :header_date_format option
  test "doesn't show month names" do
    assert_nil LaterDude::Calendar.new(2009, 1, :hide_month_name => true).send(:show_month_names)
  end

  test "uses date format for calendar header" do
    assert_match %r(January 2009), LaterDude::Calendar.new(2009, 1, :header_date_format => "%B %Y").to_html
  end

  # helper methods
  test "shows whether a given day is on a weekend or not" do
    [0, 6].each { |day| assert  LaterDude::Calendar.weekend?(mock(:wday => day)) }
    (1..5).each { |day| assert !LaterDude::Calendar.weekend?(mock(:wday => day)) }
  end

  test "includes day name abbreviation" do
    assert_equal %q(<abbr title="Sunday">Sun</abbr>), LaterDude::Calendar.new(2009, 1, :use_full_day_names => false).send(:include_day_abbreviation, "Sun")
  end

  test "doesn't include day name abbreviation" do
    assert_equal "Sunday", LaterDude::Calendar.new(2009, 1, :use_full_day_names => true).send(:include_day_abbreviation, "Sunday")
  end

  test "shows index of first and last day of week" do
    assert_equal 0, LaterDude::Calendar.new(2009, 1).send(:first_day_of_week)
    assert_equal 6, LaterDude::Calendar.new(2009, 1).send(:last_day_of_week)

    assert_equal 1, LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:first_day_of_week)
    assert_equal 0, LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:last_day_of_week)
  end

  test "applies first day of week accordingly" do
    assert_equal %w(Mon Tue Wed Thu Fri Sat Sun), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:apply_first_day_of_week, ABBR_DAY_NAMES)
  end

  test "returns the first day of the week for a given date" do
    day = Date.civil(2009, 1, 4) # first Sunday in 2009

    assert_equal Date.civil(2009, 1, 4),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 0).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 29), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 30), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 2).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 31), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 3).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 1),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 4).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 2),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 5).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 3),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 6).send(:beginning_of_week, day)
  end

  # TODO: may consider to mock some of the behavior so I don't have to use concrete months that fit for a test
  test "shows previous month if first day of month isn't the first day of a week" do
    assert_not_nil LaterDude::Calendar.new(2009, 4).send(:show_previous_month) # April 1st is a Wednesday
  end

  test "shows following month if last day of month isn't the last day of a week" do
    assert_not_nil LaterDude::Calendar.new(2009, 4).send(:show_following_month) # April 30th is a Thursday
  end

  test "shouldn't show previous month if first day of month is the first day of a week" do
    assert_nil LaterDude::Calendar.new(2009, 2).send(:show_previous_month) # February 1st is a Sunday
  end

  test "shouldn't show following month if last day of month is the last day of a week" do
    assert_nil LaterDude::Calendar.new(2009, 2).send(:show_following_month) # February 28th is a Saturday
  end

  test "highlights current day (= today)" do
    Date.stubs(:current).then.returns(Date.civil(2009, 1, 14))
    assert_match %r(<td class="(.*)today(.*)">14</td>), LaterDude::Calendar.new(2009, 1).to_html
  end

  test "shows special days as designated by a block" do
    CalendarTest.send(:include, ActionView::Helpers)

    # all even days should be linked
    special_days_proc = lambda do |day|
      if day.day.even?
        [link_to(day.day, "/calendar/#{day.year}/#{day.month}/#{day.day}"), { :class => "specialDay" } ]
      else
        day.day
      end
    end

    calendar_html = LaterDude::Calendar.new(2009, 1, &special_days_proc).to_html

    (Date.civil(2009, 1, 1)..Date.civil(2009, 1, -1)).each do |day|
      if day.day.even?
        assert_match %r(<td class="day(.*)specialDay"><a href="/calendar/#{day.year}/#{day.month}/#{day.day}">#{day.day}</a></td>), calendar_html
      else
        assert_match %r(<td class="day(.*)">#{day.day}</td>), calendar_html
        assert_no_match %r(<td class="day(.*)specialDay"><a href="/calendar/#{day.year}/#{day.month}/#{day.day}">#{day.day}</a></td>), calendar_html
      end
    end
  end

  # TODO: Should I do "real" output testing despite the good coverage of output-related methods? Testing HTML is tedious ...
end