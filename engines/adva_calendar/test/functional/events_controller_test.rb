require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class EventsControllerTest < ActionController::TestCase
  tests EventsController
  with_common :is_user, :fixed_time, :calendar_with_events

  def default_params
    { :site_id => @site.id, :section_id => @section.id, :per_page => 100, :page => 1, :format => 'html' }
  end

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  view :common do
    has_tag 'div[id=footer]'
  end

  view :index do
    shows :common
    has_tag 'form[id=calendar_search]'
    has_tag 'div[id=calendar]'
    has_tag 'div[id=events]' do |events_tag|
      assigns['events'].each do |event|
        has_tag "tr[id=calendar_event_%s]" % event.id do |tag|
          has_tag "a[href=%s]" % calendar_event_url(event.section.id, event.permalink) do |tag|
            has_text event.title
          end
          has_tag "abbr[class=datetime][title=%s]" % event.start_date.xmlschema
          has_tag "abbr[class=datetime][title=%s]" % event.end_date.xmlschema
        end
      end
    end
  end

  view :show do
    shows :common
    event = assigns['event']
    has_tag "div[id=calendar_event_%s]" % event.id do
      has_tag "div[class=content]" do
        has_text event.title
        has_text event.body
        has_text event.host
      end
      has_tag "div[class=meta]" do |tag|
        has_tag "abbr[class=datetime][title=%s]" % event.start_date.xmlschema
        has_tag "abbr[class=datetime][title=%s]" % event.end_date.xmlschema
        if event.all_day?
          has_tag 'span[class=all_day]'
        else
          assert_no_tag 'span[class=all_day]'
        end
        has_authorized_tag 'a[href=?]', edit_admin_calendar_event_path(@site, @section, event), /edit/i
        # missing: tags and categories
      end
    end
  end

  describe "GET to :index" do
    before do
      @date = Date.today
      @timespan = [@date, nil]
    end

    action { get :index, default_params}

    it_renders_view :index
    it_assigns :current_timespan => lambda { @timespan }
    it_assigns :events => lambda { @section.events.published.upcoming }
  end

  describe "GET to :index for last month" do
    before do
      @date = Date.today - 1.month
      @timespan = [@date.beginning_of_month, @date.end_of_month]
    end

    action { get :index, default_params.merge(:year => @date.year, :month => @date.month) }

    it_renders_view :index
    it_assigns :current_timespan => lambda { @timespan }
    it_assigns :events => lambda { @section.events.published.upcoming(@timespan) }
  end

  describe "GET to :index with a specific day" do
    before do
      @date = Date.today + 4.days
      @timespan = [@date.beginning_of_day, @date.end_of_day]
    end

    action { get :index, default_params.merge(:year => @date.year, :month => @date.month, :day => @date.day) }

    it_renders_view :index
    it_assigns :current_timespan => lambda { @timespan }
    it_assigns :events => lambda { @section.events.published.upcoming(@timespan) }
  end

  describe "GET to :index for recently updated events" do
    action { get :index, default_params.merge(:scope => 'recently_added') }

    it_assigns :events => lambda { @section.events.published.recently_added }
    it_renders_view :index
  end

  describe "GET to :index for elapsed updated events" do
    action { get :index, default_params.merge(:scope => 'elapsed') }

    it_assigns :events => lambda { @section.events.published.elapsed }
    it_renders_view :index
  end

   describe "GET to :index for a category" do
     action { get :index, default_params.merge(:category_id => @section.categories.first.id) }

     it_assigns :category => lambda { @section.categories.first }
     it_assigns :events => lambda { @section.events.published.by_categories(@section.categories.first.id) }
   end

  describe "GET to :show" do
    action { get :show, default_params.merge(:permalink => @section.events.published.first.permalink) }

    it_assigns :event
    it_renders_view :show
    it_renders_template :show
    it_caches_the_page :track => ['@event']
    it_does_not_sweep_page_cache
  end
end