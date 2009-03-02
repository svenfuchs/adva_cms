require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class ActiveRecordStickyChangesTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
  end

  test "does not break dirty tracking" do
    original_title = @site.title
    @site.title = 'changed title'
    @site.title_was.should == original_title
  end

  test "#state_changes returns [:created] when original state was new record" do
    @site = Site.create! :host => '2.example.com', :title => 'title', :name => 'name'
    @site.state_changes.should == [:created]
  end

  test "#state_changes returns [:updated] when original state was changed" do
    @site.update_attributes! :title => 'updated title'
    @site.state_changes.should == [:updated]
  end

  test "#state_changes returns [:deleted] when original state was frozen" do
    @site.destroy
    @site.state_changes.should == [:deleted]
  end

  test "#state_changes returns an empty array if no state changes are detected" do
    @site.state_changes.should == []
  end
end
