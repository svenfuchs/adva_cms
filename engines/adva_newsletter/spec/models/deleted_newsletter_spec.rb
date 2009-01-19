require File.dirname(__FILE__) + '/../spec_helper'

describe DeletedNewsletter do
  
  before do
    Site.delete_all
    @deleted_newsletter = Factory :deleted_newsletter
  end

  describe "methods:" do
    describe "restore" do
      it "should restore DeleteNewsletter back to Newsletter" do
        Newsletter.find_by_id(@deleted_newsletter.id).should be_nil
        DeletedNewsletter.find_by_id(@deleted_newsletter.id).should_not be_nil
        @deleted_newsletter.restore
        Newsletter.find_by_id(@deleted_newsletter.id).should_not be_nil
        DeletedNewsletter.find_by_id(@deleted_newsletter.id).should be_nil
      end
    end
  end
end
