require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CachedPagesHelperTest < ActionView::TestCase
  include CachedPagesHelper
  
  def setup
    super
    @page = CachedPage.first
    
    @time_now = Time.local 2008, 1, 2, 12
    @yesterday = Time.local 2008, 1, 1, 12
    
    stub(Time).now.returns @time_now # wtf ... time_now_in_words ignores the timezone
    stub(Time.zone).now.returns @time_now
    stub(Time.zone.now).yesterday.returns @yesterday
    stub(Date).today.returns @time_now.to_date
  end

  test '#page_cached_at returns a variant of time_ago_in_words if the cached page was updated no more than 4 hours ago' do
    @page.updated_at = @time_now - 55.minutes
    page_cached_at(@page).should == '~ 1 hour ago'
  end

  test "#page_cached_at returns a formatted date preceeded with 'Today' if the cached page was updated earlier today" do
    @page.updated_at = @time_now - 6.hours
    page_cached_at(@page).should =~ /Today, /
  end
  
  test "#page_cached_at returns a formatted date if the cached page was updated before today" do
    @page.updated_at = @yesterday
    page_cached_at(@page).should == 'Jan 01, 2008'
  end
end
