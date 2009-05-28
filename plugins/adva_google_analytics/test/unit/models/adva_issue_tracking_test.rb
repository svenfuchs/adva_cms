require File.dirname(__FILE__) + '/../../test_helper'

class AdvaIssueTrackingTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first
    @issue.published_state!.should == true #issue is now published state
    @user = @site.users.first
  end

  def teardown
    super
  end

  test "#tracking_campaign should return default value as its newsletter title" do
    @issue.tracking_campaign = nil
    @issue.tracking_campaign.should == "newsletter title"
  end

  test "#tracking_enabled? should return true when Google Analytics tracking code, campaign name and source name are set" do
    @issue.should have_tracking_enabled
  end

  test "#tracking_enabled? should return false when not tracked" do
    @issue.track = false
    @issue.should_not have_tracking_enabled
  end

  test "#traking_enabled? should return false when Google Analytics code is missing" do
    @issue.newsletter.site.google_analytics_tracking_code = nil
    @issue.should_not have_tracking_enabled
  end

  test "#tracking_enabled? should return true when campaign name is missing cos it takes newsletter title by default" do
    @issue.tracking_campaign = nil
    @issue.should have_tracking_enabled
  end

  test "#tracking_enabled? should return false when source name is missing" do
    @issue.tracking_source = nil
    @issue.should_not have_tracking_enabled
  end

  test "#body_html should track URLs when tracking is enabled" do
    @issue.body = %(<a href="http://#{@issue.newsletter.site.host}/newest-products.html?order=date">View our newest products</a>)
    @issue.save

    expected = %(<a href="http://#{@issue.newsletter.site.host}/newest-products.html?order=date&utm_medium=newsletter&utm_campaign=#{URI.escape(@issue.tracking_campaign)}&utm_source=#{URI.escape(@issue.tracking_source)}">View our newest products</a>)
    @issue.should have_tracking_enabled
    @issue.body_html.should == expected
  end

  test "#body_html should not track URLs when tracking is disabled" do
    @issue.body = %(<a href="http://#{@issue.newsletter.site.host}/newest-products.html?order=date">View our newest products</a>)
    @issue.save
    @issue.track = false

    @issue.should_not have_tracking_enabled
    @issue.body_html.should == %(<a href="http://#{@issue.newsletter.site.host}/newest-products.html?order=date">View our newest products</a>)
  end
end
