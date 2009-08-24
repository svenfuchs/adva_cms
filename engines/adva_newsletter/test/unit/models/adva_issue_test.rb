require File.dirname(__FILE__) + '/../../test_helper'

class AdvaIssueTest < ActiveSupport::TestCase
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
    Adva::Issue.should filter_attributes(:except => [:body, :body_html])
  end

  test "#editable? should be editable when state is draft or published" do
    @issue.should be_editable
    @issue.draft_state!
    @issue.should be_editable
  end

  test "#edtitable? should NOT be editable when new record" do
    issue = Adva::Issue.new
    issue.should_not be_editable
  end

  test "#editable? should NOT be editable queued or delivered" do
    @issue.state = "queued"
    @issue.should_not be_editable
    @issue.state = "delivered"
    @issue.should_not be_editable
  end

  test "#destroy should decrease issues_count by -1" do
    @newsletter = Adva::Newsletter.first
    @newsletter.issues_count.should == 1
    @newsletter.issues.first.destroy
    @newsletter.reload.issues_count.should == 0
  end

  test "#state_time should return updated_at when draft state" do
    @issue.draft_state!
    @issue.reload

    # There was some issues stubing Time out, however without stubing Time there happend sometimes strange +/- 1 second errors
    # at cruse control. Until the real reason is sorted out, there are no seconds tested.
    @issue.state_time.to_s(:short).should == @issue.updated_at.to_s(:short)
  end

  test "#state_time should return published_at when on hold state" do
    @issue.state_time.to_s(:short).should == @issue.published_at.to_s(:short)
  end

  test "#state_time should return queued_at when queued state" do
    @issue.queued_state!

    @issue.state_time.to_s(:short).should == @issue.queued_at.to_s(:short)
  end

  test "#state_time should return delivered_at when delivered state" do
    @issue.state = "queued"
    @issue.delivered_state!

    @issue.state_time.to_s(:short).should == @issue.delivered_at.to_s(:short)
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
    @issue.state.should == "hold"
  end

  test "#published_state! should remove cronjob when prevous state was queued" do
    @issue.deliver

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
    @issue.draft_state!
    @issue.draft?.should == true
  end

  test "#draft? should be true by default" do
    Adva::Issue.new.should be_draft
  end

  test "#draft? should be false when published" do
    @issue.should_not be_draft
  end

  test "#published? should be false by default" do
    Adva::Issue.new.should_not be_published
  end

  test "#published? should be true when published" do
    @issue.should be_published
  end

  test "#published? should be true when state is hold or published" do
    @issue.state = 'published'
    @issue.should be_published
    @issue.state = 'hold'
    @issue.should be_published
  end

  test "#queued? should be false by default" do
    Adva::Issue.new.should_not be_queued
  end

  test "#queued? should be true when queued" do
    @issue.state = "queued"
    @issue.should be_queued
  end

  test "#delivered? should be false by defalut" do
    Adva::Issue.new.should_not be_delivered
  end

  test "#delivered? should be true when delivered" do
    @issue.state = "queued"
    @issue.delivered_state!
    @issue.should be_delivered
  end

  test "#draft should be 1 by default" do
    Adva::Issue.new.draft.should == 1
  end

  test "#draft should be 0 when published" do
    @issue.draft.should == 0
  end

  test "#draft= should set state published when given 0" do
    @issue.state = "draft"
    @issue.draft.should == 1
    @issue.draft = 0
    @issue.should be_published
  end

  test "#draft= should set state not published when given 1" do
    @issue.draft = 1
    @issue.should_not be_published
  end

  test "#create_emails should change state to delivered" do
    @issue.state = "queued"
    @issue.create_emails
    @issue.should be_delivered
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
    @issue.deliver(:later_at => time)
  end

  test "#deliver should call deliver_to" do
    mock(@issue).deliver_to(@user)
    @issue.deliver(:to => @user)
  end

  test "#deliver should change state to queued when delivered to all" do
    @issue.deliver
    @issue.should be_queued
  end

  test "#deliver should not change state to queued when deliver to user" do
    mock(@issue).deliver_to(@user)
    @issue.deliver(:to => @user)
    @issue.should be_published
  end

  test "#deliver_all should create cronjob" do
    @issue.deliver_all.should_not == nil
    @issue.cronjob.should be_a(Adva::Cronjob)
    @issue.cronjob.should_not == nil
  end

  test "#deliver_all should change to queued state" do
    @issue.deliver_all.should_not == nil
    @issue.queued?.should == true
  end

  test "#delivered_all should return nil when state is already queued" do
    @issue.queued_state!
    @issue.deliver_all.should == nil
  end

  test "#cancel_delivery should return true" do
    @issue.deliver
    @issue.cancel_delivery.should == true
  end

  test "#cancel_delivery remove cronjob" do
    @issue.deliver
    @issue.cancel_delivery
    @issue.cronjob.should == nil
  end

  test "#cancel_delivery should set published state" do
    @issue.deliver
    @issue.cancel_delivery
    @issue.should be_published
  end

  test "#cancel_delivery should return false when issue is already delivered" do
    @issue.deliver
    @issue.cancel_delivery
    @issue.cancel_delivery.should == false
  end

  test "#body_mail should return body_html where images are replaced with inline images" do
    @issue.body = "<img src='http://example.com/image.jpg' alt='test' />"
    @issue.save
    stub(TMail).new_message_id { "<4a266bee9659c_7524..fdbeb80d8194@test.tmail>" }
    @issue.body_mail.should == "<img src='cid:4a266bee9659c_7524..fdbeb80d8194@test.tmail' alt='test' />"
  end

  test "#images should call Adva::IssueImage.parse" do
    mock(Adva::IssueImage).parse(@issue.body_html)
    @issue.images
  end
end
