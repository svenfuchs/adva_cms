require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'test_helper' ))

class TrackerIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @section = Tracker.find_by_title 'tracker'
    @site = use_site! @section.site
  end
  
  test "admin visits tracker admin page" do
    login_as_admin
    visit_tracker
  end

  def visit_tracker
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/trackers"
    renders_template "admin/tracker/index"
  end
end
