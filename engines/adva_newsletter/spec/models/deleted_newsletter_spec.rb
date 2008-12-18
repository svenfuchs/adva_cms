require File.dirname(__FILE__) + '/../spec_helper'

describe DeletedNewsletter do
  
  before do
    @deleted_newsletter = Factory :deleted_newsletter
  end

  describe "methods:" do
    describe "restore" do
      it "should restore DeleteNewsletter back to Newsletter" do
        Newsletter.find_by_id(@deleted_newsletter.id).should == nil
        DeletedNewsletter.find_by_id(@deleted_newsletter.id).should_not == nil
        @deleted_newsletter.restore
        Newsletter.find_by_id(@deleted_newsletter.id).should_not == nil
        DeletedNewsletter.find_by_id(@deleted_newsletter.id).should == nil
      end
    end
  end
end
