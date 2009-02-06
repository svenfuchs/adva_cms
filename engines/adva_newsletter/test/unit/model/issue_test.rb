require File.dirname(__FILE__) + '/../../test_helper'

class IssueTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first
    @user = @site.users.first
  end

  def teardown
    super
    remove_all_test_cronjobs
  end

  test "associations" do
    @issue.should belong_to(:newsletter)
    @issue.should have_one(:cronjob)
  end

  test "validations" do
    @issue.should be_valid
    @issue.should validate_presence_of(:title)
    @issue.should validate_presence_of(:body)
    @issue.should validate_presence_of(:newsletter_id)
  end
  
  test "sanitization" do
    Issue.should filter_attributes(:except => [:body, :body_html])
  end
  
  test "#editable? should be editable when state is draft or published" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.editable?.should == true
    @issue.draft_state!
    @issue.editable?.should == true
  end

  test "#edtitable? should NOT be editable when new record" do
    issue = Issue.new
    issue.editable?.should == false
  end
  
  test "#editable? should NOT be editable queued or delivered" do
    @issue.state = "queued"
    @issue.editable?.should == false
    @issue.state = "delivered"
    @issue.editable?.should == false
  end
  
  test "#destroy should move Issue to DeletedIssue" do
    Issue.find_by_id(@issue.id).should_not == nil
    DeletedIssue.find_by_id(@issue.id).should == nil
    @issue.destroy
    Issue.find_by_id(@issue.id).should == nil
    DeletedIssue.find_by_id(@issue.id).should_not == nil
  end
  
  test "#destroy should decrease issues_count by -1" do
    @newsletter = Newsletter.first
    @newsletter.issues_count.should == 1
    @newsletter.issues.first.destroy
    @newsletter.reload.issues_count.should == 0
  end
  
  test "#state_time should return updated_at when draft state" do
    @issue.state_time.should == @issue.updated_at
  end

  test "#state_time should return published_at when on hold state" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.state_time.should == @issue.published_at
  end
  
  test "#state_time should return queued_at when queued state" do
    @issue.state = "hold"
    @issue.queued_state!
    @issue.state_time.should == @issue.queued_at
  end
  
  test "#state_time should return delivered_at when delivered state" do
    @issue.state = "queued"
    @issue.delivered_state!
    @issue.state_time.should == @issue.delivered_at
  end
  
  test "#draft_state! should change to draft_state" do
    @issue.state = "test_state"
    @issue.state = "hold"
    @issue.draft_state!
    @issue.state.should == "draft"
  end
  
  test "#draft_state! should not allow change to draft unless published or draft" do
    @issue.state = "test_state"
    @issue.draft_state!.should == nil
    @issue.state.should == "test_state"
  end
  
  test "#published_state! should change to published state" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.state.should == "hold"
  end
  
  test "#published_state! should remove cronjob when prevous state was queued" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.queued_state!

    @issue.state.should == "queued"
    @issue.cronjob.should_not == nil

    @issue.published_state!
    @issue.cronjob.should == nil
  end
  
  test "#published_state! should not allow to change state unless state was draft or queued" do
    @issue.state = "test_state"
    @issue.published_state!.should == nil
    @issue.state.should == "test_state"
  end
  
  test "#queued_state! should change to queued state" do
    @issue.state = "hold"
    @issue.queued_state!
    @issue.state.should == "queued"
  end
  
  test "#queued_state! should not allow to change state unless state is published" do
    @issue.state = "test_state"
    @issue.queued_state!.should == nil
  end
  
  test "#delivered_state! should change to delivered state" do
    @issue.state = "queued"
    @issue.delivered_state!.should == true
    @issue.delivered?.should == true
  end
  
  test "#delivered_state! should not allow change state unless state was queued" do
    @issue.state = "test_state"
    @issue.delivered_state!.should == nil
    @issue.state.should == "test_state"
  end
  
  test "#draft! should change state to draft" do
    @issue.state = "hold"
    @issue.draft_state!
    @issue.draft?.should == true
  end

  test "#draft? should be true by default" do
    Issue.new.draft?.should == true
  end
  
  test "#draft? should be false when published" do
    @issue.published_state!
    @issue.draft?.should == false
  end
  
  test "#published? should be false by defalt" do
    Issue.new.published?.should == false
  end
  
  test "#published? should be true when published" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.published?.should == true
  end
  
  test "#published? should be true when state is hold or published" do
    @issue.state = 'published'
    @issue.published?.should == true
    @issue.state = 'hold'
    @issue.published?.should == true
  end
  
  test "#queued? should be false by default" do
    Issue.new.queued?.should == false
  end

  test "#queued? should be true when queued" do
    @issue.state = "queued"
    @issue.queued?.should == true
  end

  test "#delivered? should be false by defalut" do
    Issue.new.delivered?.should == false
  end
  
  test "#delivered? should be true when delivered" do
    @issue.state = "queued"
    @issue.delivered_state!
    @issue.delivered?.should == true
  end

  test "#draft should be 1 by default" do
    Issue.new.draft.should == 1
  end
  
  test "#draft should be 0 when published" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.draft.should == 0
  end
  
  test "#draft= should set state published when given 0" do
    @issue.state = "draft"
    @issue.draft.should == 1
    @issue.draft = 0
    @issue.published?.should == true
  end
  
  test "#draft= should set state not published when given 1" do
    @issue.draft = 1
    @issue.published?.should == false
  end
  
  test "#create_emails should change state to delivered" do
    @issue.state = "queued"
    @issue.create_emails
    @issue.delivered?.should == true
  end
  
  test "#email should provide newsletter email" do
    @issue.newsletter.email = "newsletter@example.com"
    @issue.email.should == "newsletter@example.com"
  end
  
  test "#email should provide site email when newsletter email is nil" do
    @issue.newsletter.email = nil
    @issue.newsletter.site.email = "site@example.com"
    @issue.email.should == "site@example.com"
  end
    

  test "#deliver should call deliver_all when no arguments given" do
    mock(@issue).deliver_all(nil)
    @issue.deliver
  end
  
  test "#deliver should call deliver_all with datetime" do
    time = DateTime.now
    mock(@issue).deliver_all(time)
    @issue.deliver :later_at => time
  end
  
  test "#deliver should call deliver_to" do
    mock(@issue).deliver_to(@user)
    @issue.deliver :to => @user
  end
  
  test "#deliver should change state to queued when delivered to all" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.published_state!

    @issue.deliver
    @issue.queued?.should == true
  end
  
  test "#deliver should not change state to queued when deliver to user" do
    @issue.state = "draft"
    @issue.published_state!
    @issue.deliver :to => @user
    @issue.published?.should == true
  end
  
  test "#deliver_all should create cronjob" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.cronjob.should == nil
    @issue.published_state!

    @issue.deliver_all.should_not == nil

    @issue.cronjob.class.should == Cronjob
    @issue.cronjob.should_not == nil
  end
  
  test "#deliver_all should change to queued state" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.published_state!

    @issue.state.should == "hold"
    @issue.deliver_all.should_not == nil

    @issue.state.should == "queued"
  end
  
  test "#delivered_all should return nil when state is already queued" do
    @issue.queued_state!
    @issue.deliver_all.should == nil
  end
  
  test "#cancel_delivery should return true" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.published_state!

    @issue.deliver
    @issue.cancel_delivery.should == true
  end
  
  test "#cancel_delivery remove cronjob" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.published_state!

    @issue.deliver
    @issue.cancel_delivery
    @issue.cronjob.should == nil
  end
  
  test "#cancel_delivery should set published state" do
    @issue.cronjob.destroy
    @issue.reload
    @issue.state = "draft"
    @issue.published_state!

    @issue.deliver
    @issue.cancel_delivery
    @issue.published?.should == true
  end
  
  test "#cancel_delivery should return false when issue is already delivered" do
    @issue.published_state!
    @issue.deliver
    @issue.cancel_delivery
    @issue.cancel_delivery.should == false
  end

  test "#has_tracking_enabled? should be tracked and Google Analytics tracking code, campaign name and source name are set" do
    # @issue.stub!(:track?).and_return(true)
    # @issue.stub!(:tracking_campaign).and_return("Test campaign")
    # @issue.stub!(:tracking_source).and_return("Test source")
    # @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

    # @issue.should have_tracking_enabled
  end
  
  test "#has_tracking_disabled? should be true when not tracked" do
    # @issue.stub!(:track?).and_return(false)
    # @issue.stub!(:tracking_campaign).and_return("Test campaign")
    # @issue.stub!(:tracking_source).and_return("Test source")
    # @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

    # @issue.should_not have_tracking_enabled
  end

  test "#has_traking_disable should be true when Google Analytics code is missing" do
    # @issue.stub!(:track?).and_return(true)
    # @issue.stub!(:tracking_campaign).and_return("Test campaign")
    # @issue.stub!(:tracking_source).and_return("Test source")
    # @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return(nil)

    # @issue.should_not have_tracking_enabled
  end

  test "#has_tracking_disabled should be true when campaign name is missing" do
    # @issue.stub!(:track?).and_return(true)
    # @issue.stub!(:tracking_campaign).and_return(nil)
    # @issue.stub!(:tracking_source).and_return("Test source")
    # @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

    # @issue.should_not have_tracking_enabled
  end
  
  test "#has_tracking_disabled should be true when source name is missing" do
    # @issue.stub!(:track?).and_return(true)
    # @issue.stub!(:tracking_campaign).and_return("Test campaign")
    # @issue.stub!(:tracking_source).and_return(nil)
    # @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

    # @issue.should_not have_tracking_enabled
  end
  
  test "#body_html should track URLs when tracking is enabled" do
    # before(:each) do
      # @issue.stub!(:tracking_campaign).and_return("test-campaign")
      # @issue.stub!(:tracking_source).and_return("test-source")
      # @issue.body = '<a href="http://www.example.com/newest-products.html?order=date">View our newest products</a>'
      # @issue.save
    # end
    # @issue.stub!(:has_tracking_enabled?).and_return(true)

    # @issue.body_html.should == 
    # '<a href="http://www.example.com/newest-products.html?order=date&utm_medium
    # =newsletter&utm_campaign=test-campaign&utm_source=test-source">View our newest products</a>'
  end
  
  test "#body_html should not track URLs when tracking is disabled" do
    # @issue.stub!(:has_tracking_enabled?).and_return(false)
    # @issue.body_html.should == 
    # '<a href="http://www.example.com/newest-products.html?order=date">View our newest products</a>'
  end
end
