require File.dirname(__FILE__) + '/../spec_helper'
require 'base_helper'
require 'content_helper'
require 'roles_helper'

describe "Album views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @user   = Factory :user
    @site   = Factory :site
    @album  = Factory :album, :site => @site
    @photo  = Factory :photo, :section => @album, :author => @user
    @set    = Factory :set, :section => @album
    assigns[:set]     = nil
    assigns[:tags]    = nil
    assigns[:photos]  = @album.photos
    assigns[:site]    = @site
    assigns[:section] = @album
    #template.stub!(:current_user).and_return(@user)
    #template.stub!(:admin_sections_path).and_return admin_sections_path(@site.id)
    template.extend BaseHelper
    template.extend ContentHelper
    template.extend RolesHelper
  end
  
  describe "GET to index" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'photo')
      template.stub!(:render).with hash_including(:partial => 'footer')
    end
    act! { render "albums/index" }
    
    it "should render photo partial" do
      template.should_receive(:render).with hash_including(:partial => 'photo')
      act!
    end
  
    it "should render footer partial" do
      template.should_receive(:render).with hash_including(:partial => 'footer')
      act!
    end
  end
  
  describe "GET to show" do
    # act! { render "albums/show" }
    # 
  end
  
  describe "_photo" do
    before :each do
      template.stub!(:photo).and_return @photo
      template.stub!(:mode).and_return :multi
    end
    act! { render "albums/_photo" }

    it "should display the photo" do
      render :partial => "albums/photo", :object => @photo, :locals => {:mode => :many}
      response.should have_tag('div.entry')
    end

    it "should list the photo's tags" do
      template.should_receive(:links_to_content_tags)
      act!
    end

    it "should list the photo's sets" do
      template.should_receive(:links_to_photo_sets)
      act!
    end
  end
end