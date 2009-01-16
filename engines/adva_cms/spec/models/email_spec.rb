require File.dirname(__FILE__) + '/../spec_helper'

describe Email do
  before do
    @email = Factory :email
  end

  describe "validations:" do
    it "should be valid" do
      @email.should be_valid
    end

    it "should have from" do
      @email.from = nil
      @email.should_not be_valid
    end
    
    it "should have to" do
      @email.to = nil
      @email.should_not be_valid
    end
    
    it "should have mail" do
      @email.mail = nil
      @email.should_not be_valid
    end
  end
  
  describe "methods:" do
    describe "self.create_cronjob" do
      it "should create cronjob" do
        response = Email.create_cronjob
        response.class.should == Cronjob 
        response.command.should == "Email.deliver_all"
      end
    end
    
    describe "self.deliver_all" do
      it "should remove cronjob when all emails are delivered" do
        Cronjob.create :cron_id => "email_deliver_all", :command => "test"
        Email.destroy_all
        Email.deliver_all
        Cronjob.find_by_cron_id("email_deliver_all").should == nil
      end
    end
  end
  
  after do
    remove_all_test_cronjobs
  end
end
