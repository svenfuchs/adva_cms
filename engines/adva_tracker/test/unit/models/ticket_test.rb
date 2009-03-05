require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class TicketTest < ActiveSupport::TestCase
  def setup
    super
    @section = Tracker.find_by_title("tracker")
    @project = @section.projects.first
    @ticket = @project.tickets.first
  end
  
  test "associations" do
    @ticket.should belong_to(:ticketable)
  end
  
  test "validations" do
    @ticket.should validate_presence_of(:title)
    @ticket.should validate_presence_of(:body)
    @ticket.should validate_presence_of(:ticketable_id)
    @ticket.should validate_presence_of(:ticketable_type)
    @ticket.should validate_presence_of(:author_id)
    @ticket.should validate_presence_of(:author)
  end
  
  test "sanitization" do
    Ticket.should filter_attributes(:except => [:body, :body_html])
  end
end
