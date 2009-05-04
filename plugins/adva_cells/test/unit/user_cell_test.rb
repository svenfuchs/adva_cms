require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserCellTest < ActiveSupport::TestCase
  def setup
    super
    @controller   = CellTestController.new
    @cell         = UserCell.new(@controller)
  end
  
  test "#recent sets the users from latest 5 users, ordered by 'id DESC' as a default" do
    @cell.recent
    @cell.instance_variable_get(:@users).should == recent_users
  end
  
  test "#recent user amount can be altered by @opts[:count]" do
    @cell.instance_variable_set(:@opts, { :count => 1 })
    @cell.recent
    @cell.instance_variable_get(:@users).should == recent_users("id DESC", 1)
  end
  
  # FIXME test the cached_references
  # FIXME test the has_state option
  
  def recent_users(order = "id DESC", limit = 5)
    User.all(:order => order, :limit => limit)
  end
end