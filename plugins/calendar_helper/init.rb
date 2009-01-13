require File.join(File.dirname(__FILE__), 'lib', 'calendar_helper')

ActionView::Base.send :include, CalendarHelper
