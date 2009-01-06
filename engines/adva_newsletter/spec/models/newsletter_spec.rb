require File.dirname(__FILE__) + '/../spec_helper'

describe BaseNewsletter do
  
  before :each do
    Site.delete_all
    @issue = Factory :newsletter
  end

  describe "validations:" do
    it "should have title" do
      @issue.title = nil
      @issue.should_not be_valid
    end
  end
end

describe Newsletter do
  
  before do
    Site.delete_all
    factory_scenario :site_with_two_users_and_newsletter
  end

  describe "methods:" do
    describe "destroy" do
      it "should move Newsletter to DeletedNewsletter" do
        Newsletter.find_by_id(@newsletter.id).should_not == nil
        DeletedNewsletter.find_by_id(@newsletter.id).should == nil
        @newsletter.destroy
        Newsletter.find_by_id(@newsletter.id).should == nil
        DeletedNewsletter.find_by_id(@newsletter.id).should_not == nil
      end
    end
    
    describe "available_users" do
      it "should provide all site users except already subscribed to the newsletter" do
        @newsletter.available_users.count.should == 2
        new_subscriber = @newsletter.subscriptions.create :user_id => @site.users.first.id
        @newsletter.available_users.count.should == 1
      end
    end
  end
end
