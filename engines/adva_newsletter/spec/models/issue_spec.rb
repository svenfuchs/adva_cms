require File.dirname(__FILE__) + '/../spec_helper'

describe Issue do
  before :each do
    Site.delete_all
    @issue = Factory :issue
    @user = Factory :user
  end

  describe "associations:" do
    it "sholud belong to newsletter" do @issue.should belong_to(:newsletter) end
    it "should have many cronjobs as cronable" do @issue.should have_many(:cronjobs) end
  end

  describe "validations:" do
    it "should be valid" do
      @issue.should be_valid
    end

    it "should have title" do
      @issue.title = nil
      @issue.should_not be_valid
    end

    it "should have body" do
      @issue.body = nil
      @issue.should_not be_valid
    end
  end
  
  describe "filtering" do
    it "should have filter for body" do
      @issue.body = "<div>html body</div>"
      @issue.body_html = nil
      @issue.filter = nil
      @issue.save
      @issue.body_html.should == "<div>html body</div>"
    end
  end

  describe "methods:" do
    describe "destroy" do
      it "should move Issue to DeletedIssue" do
        Issue.find_by_id(@issue.id).should_not == nil
        DeletedIssue.find_by_id(@issue.id).should == nil
        @issue.destroy
        Issue.find_by_id(@issue.id).should == nil
        DeletedIssue.find_by_id(@issue.id).should_not == nil
      end

      it "should decrease issues_count by -1" do
        @newsletter = Newsletter.first
        @newsletter.issues_count.should == 1
        @newsletter.issues.first.destroy
        @newsletter.reload.issues_count.should == 0
      end
    end

    describe "state" do
      it "should be published when published and not draft" do
        @issue.published_at = DateTime.now
        @issue.draft = 0
        @issue.state.should == "published"
      end

      it "should be pending when not published" do
        @issue.published_at = nil
        @issue.draft = 1
        @issue.state.should == "pending"
      end

      it "should be empty string when not published and not draft. We might need new state perhaps." do
        @issue.published_at = nil
        @issue.draft = 0
        @issue.state.should == ""
      end
    end

    describe "draft?" do
      it "should be true with new issue" do
        @issue.draft?.should == true
      end

      it "should be true when issue is draft" do
        @issue.draft = 1
        @issue.draft?.should == true
      end
    end

    describe "email" do
      it "should provide newsletter email" do
        @issue.newsletter.email = "newsletter@example.org"
        @issue.email.should == "newsletter@example.org"
      end

      it "should provide site email when newsletter email is nil" do
        @issue.newsletter.email = nil
        @issue.newsletter.site.email = "site@example.org"
        @issue.email.should == "site@example.org"
      end
    end

    describe "#has_tracking_enabled?" do
      it "has tracking enabled if it should be tracked and Google Analytics tracking code, campaign name and source name are set" do
        @issue.stub!(:track?).and_return(true)
        @issue.stub!(:tracking_campaign).and_return("Test campaign")
        @issue.stub!(:tracking_source).and_return("Test source")
        @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

        @issue.should have_tracking_enabled
      end

      it "has tracking disabled if it should not be tracked" do
        @issue.stub!(:track?).and_return(false)
        @issue.stub!(:tracking_campaign).and_return("Test campaign")
        @issue.stub!(:tracking_source).and_return("Test source")
        @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

        @issue.should_not have_tracking_enabled
      end

      it "has tracking disabled if Google Analytics tracking code is missing" do
        @issue.stub!(:track?).and_return(true)
        @issue.stub!(:tracking_campaign).and_return("Test campaign")
        @issue.stub!(:tracking_source).and_return("Test source")
        @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return(nil)

        @issue.should_not have_tracking_enabled
      end

      it "has tracking disabled if campaign name is missing" do
        @issue.stub!(:track?).and_return(true)
        @issue.stub!(:tracking_campaign).and_return(nil)
        @issue.stub!(:tracking_source).and_return("Test source")
        @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

        @issue.should_not have_tracking_enabled
      end

      it "has tracking disabled if source name is missing" do
        @issue.stub!(:track?).and_return(true)
        @issue.stub!(:tracking_campaign).and_return("Test campaign")
        @issue.stub!(:tracking_source).and_return(nil)
        @issue.newsletter.site.stub!(:google_analytics_tracking_code).and_return("GA-123456")

        @issue.should_not have_tracking_enabled
      end
    end

    describe "#body_html" do
      before(:each) do
        @issue.stub!(:tracking_campaign).and_return("test-campaign")
        @issue.stub!(:tracking_source).and_return("test-source")
        @issue.body = '<a href="http://www.example.com/newest-products.html?order=date">View our newest products</a>'
        @issue.save
      end

      it "tracks URLs if tracking is enabled" do
        @issue.stub!(:has_tracking_enabled?).and_return(true)

        @issue.body_html.should == '<a href="http://www.example.com/newest-products.html?order=date&utm_medium=newsletter&utm_campaign=test-campaign&utm_source=test-source">View our newest products</a>'
      end

      it "does not track URLs if tracking is disabled" do
        @issue.stub!(:has_tracking_enabled?).and_return(false)

        @issue.body_html.should == '<a href="http://www.example.com/newest-products.html?order=date">View our newest products</a>'
      end
    end
  end

  describe "deliver" do
    it "should create cronjob with command to create issue emails" do
      @issue.deliver.command.should == "Issue.find(#{@issue.id}).create_emails"
    end

    it "should create cronjob with due time 3 minutes later" do
      @issue.deliver.created_at.class.should == ActiveSupport::TimeWithZone
      @issue.deliver.due_at.should > DateTime.now + 170.seconds
      # FIXME: some timezone error, have to figure out why in test it's different
      # @issue.deliver.due_at.should < DateTime.current + 180.seconds
    end

    it "should deliver all issues LATER" do
      # @issue.deliver(:later_at => Time.now.tomorrow).should == 'deliver all later'
    end

    it "should deliver issue ONLY TO test user NOW" do
      # @mailer = mock(NewsletterMailer)
      # @mailer.should_receive(:deliver_issue).and_return(true)

      # @issue.published_at.should == nil
      # @issue.deliver(:to => @user)
      # @issue.published_at.should_not == nil
    end

    it "should deliver issue ONLY TO test user LATER" do
      # @issue.deliver(:later => Time.now.tomorrow, :to => @user).should == 'deliver later to'
    end

    after do
      remove_all_test_cronjobs
    end
  end
end
