require File.dirname(__FILE__) + '/../spec_helper'

describe "Photo views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @album  = Factory :album, :site => @site
    @author = Factory :user
    @album.photos.create! :title => 'photo 1', :author => @author
    @album.photos.create! :title => 'photo 2', :author => @author
    assigns[:photos] = @album.photos
    assigns[:site]   = @site
  end
  
  describe "GET to index" do
    describe "with array of photos" do
      before :each do
        @album.photos.stub!(:total_entries).and_return(10)
        template.stub!(:render).with hash_including(:photo)
        template.stub!(:will_paginate).and_return('will paginate')
      end
      act! { render "admin/photos/index" }
    
      it "should show total of photo entries in album" do
        act!
        response.should have_tag('p.total')
      end
    
      it "should have list of photos" do
        act!
        response.should have_tag('table#photos.list')
      end
    
      it "should render photo partial" do
        template.should_receive(:render).with hash_including(:partial => 'photo')
        act!
      end
    
      it "paginates the photos" do
        template.should_receive(:will_paginate)
        act!
      end
    end
    
    describe "with empty array" do
      before :each do
        assigns[:photos] = []
        template.stub!(:new_admin_photo_path).and_return('new_admin_photo_path')
      end
      act! { render "admin/photos/index" }
    
      it "should have an empty list" do
        act!
        response.should have_tag('div.empty')
      end
      
      it "has a link to upload a photo" do
        act!
        response.should have_tag("a[href=?]", 'new_admin_photo_path')
      end
    end
  end
end