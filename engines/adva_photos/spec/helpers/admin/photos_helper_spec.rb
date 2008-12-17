require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PhotosHelper do
  describe "methods:" do
    describe "#label_text_for_photo" do
      before :each do
        @album      = Factory :album
        @user       = Factory :user
        @photo      = Factory :photo, :section => @album, :author => @user
        @new_photo  = Photo.new(Factory.attributes_for(:photo, :section => @album, :author => @user))
      end
      
      it "returns 'Choose a photo' string if photo is a new record" do
        helper.label_text_for_photo(@new_photo).should == 'Choose a photo'
      end

      it "returns 'Replace the photo' string if photo is an existing record" do
        helper.label_text_for_photo(@photo).should == 'Replace the photo'
      end
    end
  end
end