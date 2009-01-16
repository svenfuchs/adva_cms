require File.dirname(__FILE__) + '/../spec_helper'

describe BaseNewsletter do
  
  before :each do
    Site.delete_all
    @newsletter = Factory :newsletter
  end
  
  describe "validations:" do
    it "should have title" do
      @newsletter.title = nil
      @newsletter.should_not be_valid
    end
  end
end

describe Newsletter do
  
  before :each do
    Site.delete_all
    factory_scenario :site_with_two_users_and_newsletter
  end

  describe "associations:" do
    it "sholud have many issues" do @newsletter.should have_many(:issues) end
    it "should have deleted issues" do @newsletter.should have_many(:deleted_issues) end
    it "should have many subscriptions" do @newsletter.should have_many(:subscriptions) end
    it "should have many users" do @newsletter.should have_many(:users) end
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
        @newsletter.available_users.size.should == 2
        new_subscriber = @newsletter.subscriptions.create :user_id => @site.users.first.id
        @newsletter.available_users.size.should == 1
      end
    end
    
    describe "default_email" do
      it "should provide site.email when newsletter.email is nil" do
        @newsletter.email = nil
        @newsletter.site.email = "admin@example.org"
        @newsletter.default_email.should == "admin@example.org"
      end
    end
    
    describe "do_not_save_default_email" do
      it "should not save email when it is same as site.email" do
        @newsletter.site.email = "admin@example.org"
        @newsletter.email = "admin@example.org"
        @newsletter.save
        @newsletter.email.should == nil
      end
    end
    
    describe "published?" do
      it "should be true if published" do
        @newsletter.published = 1
        @newsletter.published?.should == true
      end
      
      it "should be fales if not published" do
        @newsletter.published = 0
        @newsletter.published?.should == false
      end
    end
    
    describe "state" do
      it "should be pending when not published" do
        @newsletter.published = 0
        @newsletter.state.should == "pending"
      end
      
      it "should be published when published" do
        @newsletter.published = 1
        @newsletter.state.should == "published"
      end
    end
    
  end
end
