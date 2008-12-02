require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesHelper do
  describe "methods:" do
    describe "#recipients_list" do
      before :each do
        Site.delete_all
        @site         = Factory :site
        @don_macaroni = Factory :don_macaroni
        @johan_mcdoe  = Factory :johan_mcdoe
        @site.users   << @don_macaroni
        @site.users   << @johan_mcdoe
      end
      
      it "should populate the list with the members of the site" do
        helper.recipients_list(@site).should == [[@don_macaroni.name, @don_macaroni.id],
                                                [@johan_mcdoe.name, @johan_mcdoe.id]]
      end
    end
    
    describe "#message_type" do
      before :each do
        @message      = Factory :message
        @johan_mcdoe  = Factory :johan_mcdoe
        helper.stub!(:current_user).and_return(@johan_mcdoe)
      end
      
      it "returns a message_recipient if current user was recipient of the message" do
        helper.message_type(@message).should == "message_recipient"
      end
      
      it "returns a message_sender if current user was sender of the message" do
        @message.update_attribute(:sender, @johan_mcdoe)
        helper.message_type(@message).should == "message_sender"
      end
    end
  end
end