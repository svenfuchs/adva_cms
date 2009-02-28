require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ProjectTest < ActiveSupport::TestCase
  def setup
    super
    @section = Tracker.find_by_title("tracker")
    @project = @section.projects.first
  end
  
  test "associations" do
    @project.should belong_to(:tracker)
  end
  
  test "validations" do
    @project.should be_valid
    @project.should validate_presence_of(:title)
  end
  
  test "#editable? should NOT be editable when new record" do
    new_project = Project.new
    new_project.editable?.should == false
  end
end
