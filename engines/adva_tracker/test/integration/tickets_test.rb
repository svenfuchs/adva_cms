require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TicketsIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @section = Tracker.find_by_title 'tracker'
    @site = use_site! @section.site
    @project = @section.projects.first
    @project.tickets.destroy_all
  end
  
  test "manage tickets" do
    login_as_admin
    view_empty_tickets
    create_new_ticket_with_failure
  end
  
  def view_empty_tickets
    visit "/tracker/projects/#{@project.id}/tickets"
    
    renders_template "tickets/index"
    response.body.should have_tag(".empty", "There are no tickets.")
  end

  def create_new_ticket_with_failure
    # renders_template "tracker/show"
    # FIXME: why (only in test) link goes to "/tickets/new", but should go "tracker/tickets/new"?
    # click_link "Create a new ticket"
    visit "/tracker/projects/#{@project.id}/tickets/new"

    renders_template "tickets/new"
    # fill_in :ticket_title, :with => nil
    # fill_in :ticket_body,  :with => nil
    # click_button "Save"

    # renders_template "tickets/new"
    # renders_flash "Ticket creation failed"
    # response.body.should have_tag(".field_with_error")
  end
end
