require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class EventsControllerTest < ActionController::TestCase
  tests EventsController
  with_common :is_user, :fixed_time, :calendar_with_events

  def default_params
    { :site_id => @site.id, :section_id => @section.id, :per_page => 100, :page => 1 }
  end

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to :index" do
    action { get :index, default_params}
    it_assigns :current_timespan => [Date.today, nil]
    it_assigns :events => lambda { @section.events.published.upcoming }
  end

  describe "GET to :index for last month" do
    action { get :index, default_params.merge(:year => Date.today.year, :month => Date.today.month - 1) }
    timespan = [(Date.today - 1.month).beginning_of_month, (Date.today - 1.month).end_of_month]
    it_assigns :current_timespan => timespan
    it_assigns :events => lambda { @section.events.published.upcoming(timespan) }
  end

  describe "GET to :index with a specific day" do
    action { get :index, default_params.merge(:year => Date.today.year, :month => Date.today.month, :day => Date.today.day + 4) }
    timespan = [Date.today + 4.days, (Date.today + 4.days).end_of_day]
    it_assigns :current_timespan => timespan
    it_assigns :events => lambda { @section.events.published.upcoming( timespan ) }
  end
  
  describe "GET to :index for recently updated events" do
    action { get :index, default_params.merge(:scope => 'recently_added') }
    it_assigns :events => lambda { @section.events.published.recently_added }
  end
  describe "GET to :index for elapsed updated events" do
    action { get :index, default_params.merge(:scope => 'elapsed') }
    it_assigns :events => lambda { @section.events.published.elapsed }
  end

# fails to find the category.
#  describe "GET to :index for a category" do
#    action { get :index, :category_id => @section.categories.first.id }
#    it_assigns :categories => lambda { @section.categories.first }
#    it_assigns :events => lambda { @section.events.published.by_categories(@section.categories.first.id) }
#  end

  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @section.events.published.first.permalink) }
    it_assigns :event
    it_renders_template :show
    it_caches_the_page :track => ['@event']
    it_does_not_sweep_page_cache
  end
end