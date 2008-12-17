require File.dirname(__FILE__) + '/../spec_helper'
require 'base_helper'
require 'content_helper'
require 'admin/comments_helper'

describe "Photo views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @album  = Factory :album, :site => @site
    @author = Factory :user
    @album.photos.create! Factory.attributes_for(:photo, :author => @author)
    @album.photos.create! Factory.attributes_for(:photo_2, :author => @author)
    assigns[:site]    = @site
    assigns[:section] = @album
    assigns[:photos]  = @album.photos
    assigns[:photo]   = @album.photos.first
    
    template.stub!(:current_user).and_return @author
    template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:photo, @photo, template, {}, nil)
    template.extend BaseHelper
    template.extend ContentHelper
    template.extend Admin::CommentsHelper
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
  
  describe "GET to new" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'form')
    end
    act! { render "admin/photos/new" }
    
    it "should render the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      act!
    end
    
    it "should have the cancel link" do
      act!
      response.should have_tag('a[href=?]', "/admin/sites/#{@site.id}/sections/#{@album.id}/photos")
    end
    
    it "should have the form button for sending the message" do
      act!
      response.should have_tag('input[name=?]', 'commit')
    end
  end
  
  describe "_form" do
    before :each do
      template.stub!(:render).with hash_including(:options)
    end
    act! { render "admin/photos/_form" }
    
    it "should render the options partial" do
      template.should_receive(:render).with hash_including(:partial => 'options')
      act!
    end
    
    it "should have the title input label" do
      act!
      response.should have_tag('label[for=?]', 'photo_title')
    end
    
    it "should have the title input field" do
      act!
      response.should have_tag('input[name=?]', 'photo[title]')
    end
    
    it "should have the file upload label" do
      act!
      response.should have_tag('label[for=?]', 'photo_uploaded_data')
    end
    
    it "should have the file upload field" do
      act!
      response.should have_tag('input[name=?][type=?]', 'photo[uploaded_data]', 'file')
    end
  end
  
  describe "_options" do
    act! { render 'admin/photos/_options' }
    
    it "should have link to photos" do
      act!
      response.should have_tag('a[href=?]', "/admin/sites/#{@site.id}/sections/#{@album.id}/photos")
    end
    
    it "should have link to album settings" do
      act!
      response.should have_tag('a[href=?]', "/admin/sites/#{@site.id}/sections/#{@album.id}/edit")
    end
    
    it "should have the author label" do
      act!
      response.should have_tag('label[for=?]', 'photo_author')
    end
    
    it "should have the author select box" do
      act!
      response.should have_tag('select[name=?]', 'photo[author]')
    end
    
    it "should have the filter label" do
      act!
      response.should have_tag('label[for=?]', 'photo_filter')
    end
    
    it "should have the filter selectbox" do
      act!
      response.should have_tag('select[name=?]', 'photo[filter]')
    end
    
    it "should have the comment_age label" do
      act!
      response.should have_tag('label[for=?]', 'photo_comment_age')
    end
    
    it "should have the comment_age selectbox" do
      act!
      response.should have_tag('select[name=?]', 'photo[comment_age]')
    end
    
    it "should have the tag_list label" do
      act!
      response.should have_tag('label[for=?]', 'photo_tag_list')
    end
    
    it "should have the input field for tag_list" do
      act!
      response.should have_tag('input[name=?]', 'photo[tag_list]')
    end
  end
  
  describe "_photo" do
    before :each do
      @photo = @album.photos.first
      template.stub!(:photo).and_return(@photo)
      template.stub! :published_at_formatted
      @photo.stub!(:comments).and_return []
    end
    act! { render 'admin/photos/_photo' }
    
    it "should have link to edit photo" do
      act!
      response.should have_tag('a[href=?]', edit_admin_photo_path(@site, @album, @photo))
    end
    
    it "should have link to author" do
      act!
      response.should have_tag('a[href=?]', admin_site_user_path(@site, @author))
    end
    
    it "should have link to delete photo" do
      act!
      response.should have_tag('a.delete')
    end
    
    it "should check if photo has comments enabled" do
      @photo.should_receive(:accept_comments?).and_return false
      act!
    end
  end
end