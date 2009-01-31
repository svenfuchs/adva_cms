require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CachedPagesHelperTest < ActiveSupport::TestCase
  include CachedPagesHelper
  include ActionView::Helpers::DateHelper
  
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

  test '#cached_page_date returns a variant of time_ago_in_words if the cached page was updated no more than 4 hours ago' do
    @page.updated_at = @time_now - 55.minutes
    cached_page_date(@page).should == '~ 1 hour ago'
  end

  test "#cached_page_date returns a formatted date preceeded with 'Today' if the cached page was updated earlier today" do
    @page.updated_at = @time_now - 6.hours
    cached_page_date(@page).should =~ /Today, /
  end
  
  test "#cached_page_date returns a formatted date if the cached page was updated before today" do
    @page.updated_at = @yesterday
    cached_page_date(@page).should == 'Jan 01, 2008'
  end
end
