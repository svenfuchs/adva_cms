require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContentCellTest < ActiveSupport::TestCase
  def setup
    super
    @controller   = CellTestController.new
    @cell         = ContentCell.new(@controller)
  end
  
  test "#recent sets the content from latest 10 published content items, ordered by 'created_at DESC' as a default" do
    @cell.recent
    @cell.instance_variable_get(:@content).should == recent_content
  end
  
  test "#recent content item amount can be altered by @opts[:limit]" do
    @cell.instance_variable_set(:@opts, { :count => 1 })
    @cell.recent
    @cell.instance_variable_get(:@content).should == recent_content("created_at DESC", 1)
  end
  
  test "#recent content ordering can be altered by @opts[:order]" do
    @cell.instance_variable_set(:@opts, { :order => "updated_at DESC" })
    @cell.recent
    @cell.instance_variable_get(:@content).should == recent_content("updated_at DESC")
  end
  
  # FIXME test the cached_references
  # FIXME test the has_state option
  
  def recent_content(order = "created_at DESC", limit = 5)
    Content.published(:order => order, :limit => limit)
  end
end