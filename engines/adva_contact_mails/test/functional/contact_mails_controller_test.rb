require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
include Authentication::HashHelper

class ContactMailsControllerTest < ActionController::TestCase
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
end