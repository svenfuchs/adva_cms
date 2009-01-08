CalendarHelper
==============

A simple helper for creating an HTML calendar. The "calendar" method will be automatically available to your view templates.

There is also a Rails generator that copies some stylesheets for use alone or alongside existing stylesheets.

Usage
=====

  # Simple
  calendar(:year => 2005, :month => 6)
  
  # Set table class
  calendar({:year => 2005, :month => 6, :table_class => "calendar_helper"})
  
  # Full featured
  calendar(:year => 2005, :month => 5) do |d| # This generates a simple calendar, but gives special days
    if listOfSpecialDays.include?(d)          # (days that are in the array listOfSpecialDays) one CSS class,
      [d.mday, {:class => "specialDay"}]      # "specialDay", and gives the rest of the days another CSS class,
    else                                      # "normalDay". You can also use this highlight today differently
      [d.mday, {:class => "normalDay"}]       # from the rest of the days, etc.
    end
  end

If using with ERb (Rails), put in a printing tag.

  <%= calendar(:year => @year, :month => @month, :first_day_of_week => 1) do |d|
        render_calendar_cell(d)
      end
  %>

With Haml, use a helper to set options for each cell.

  = calendar(:year => @year, :month => @month, :first_day_of_week => 1) do |d|
    - render_calendar_cell(d)

Authors
=======

Jeremy Voorhis -- http://jvoorhis.com
Original implementation

Geoffrey Grosenbach -- http://nubyonrails.com
Test suite and conversion to a Rails plugin

Contributors
============

* Jarkko Laine http://jlaine.net/
* Tom Armitage http://infovore.org
* Bryan Larsen http://larsen.st

Usage
=====

See the RDoc (or use "rake rdoc").

To copy the CSS files, use

  ./script/generate calendar_styles

CSS will be copied to subdirectories of public/stylesheets/calendar.

