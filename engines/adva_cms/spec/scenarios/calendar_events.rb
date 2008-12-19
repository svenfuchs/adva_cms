scenario :calendar_with_events do
  stub_scenario :empty_site

  @section = @calendar = stub_calendar
  @event = stub_calendar_event
  @events = stub_calendar_events
  @category = stub_category(:category)
  @categories = stub_categories


  CalendarEvent.stub!(:total_entries).and_return 2
  @event.stub!(:location).and_return stub_location

  @category.stub!(:contents).and_return(@events)

  Category.stub!(:find).and_return @category
  Category.stub!(:find_by_path).and_return @category
  @calendar.categories.stub!(:find_by_path).and_return @category

  Tag.stub!(:find).and_return stub_tags(:all)

  Section.stub!(:find).and_return @calendar
  @site.sections.stub!(:find).and_return @calendar
  @site.sections.stub!(:root).and_return @calendar

end
