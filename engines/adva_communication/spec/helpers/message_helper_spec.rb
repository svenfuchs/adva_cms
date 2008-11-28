require File.dirname(__FILE__) + '/../spec_helper'

describe MessageHelper do
  describe "methods:" do
    describe "#recipient_list" do
      before :each do
        Site.delete_all
        @site         = Factory :site
        @don_macaroni = Factory :don_macaroni
        @johan_mcdoe  = Factory :johan_mcdoe
        @site.users   << @don_macaroni
        @site.users   << @johan_mcdoe
      end
      
      it "should populate the list with the members of the site" do
        helper.recipient_list(@site).should == [[@don_macaroni.name, @don_macaroni.id],
                                                [@johan_mcdoe.name, @johan_mcdoe.id]]
      end
    end
  end
end