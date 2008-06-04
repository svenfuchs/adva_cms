require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Sites Views:" do
  include SpecViewHelper
  
  before :each do
    scenario :site, :section, :user

    set_resource_paths :site, '/admin/'
    template.stub!(:admin_sites_path).and_return @collection_path
    template.stub!(:admin_site_path).and_return @member_path
    
    template.stub!(:will_paginate)
    template.stub!(:todays_short_date)
  end
  
  describe "the :index view" do
    it "displays a list of sites" do
      assigns[:sites] = @sites
      render "admin/sites/index"
      response.should have_tag('#sites tbody tr', 2)
    end
  end

  describe "the :show view" do
    before :each do
      template.stub_render hash_including(:partial => 'admin/activities/activities')
      template.stub_render hash_including(:partial => 'user_activity')
      template.stub_render hash_including(:partial => 'unapproved_comments')
    end
    
    it "renders activities list partial" do
      template.expect_render hash_including(:partial => 'admin/activities/activities')
      render "admin/sites/show"
    end
    
    it "renders user_activities partial" do
      template.expect_render hash_including(:partial => 'user_activity')
      render "admin/sites/show"
    end
    
    it "renders unapproved_comments partial" do
      template.expect_render hash_including(:partial => 'unapproved_comments')
      render "admin/sites/show"
    end
  end
  
  describe "the :new view" do
    before :each do
      assigns[:site] = @site
      assigns[:section] = @section
      template.stub_render :partial => 'form', :locals => hash_including(:site => @site)
    end
    
    it "has a form tag that POSTs to collection_path" do
      render "admin/sites/new"
      response.should have_tag("form[action=?][method=?]", @collection_path, :post)
    end
    
    it "renders the site form partial" do
      template.expect_render :partial => 'form', :locals => hash_including(:site => @site)
      render "admin/sites/new"
    end
    
    it "renders fields for a new root section" do
      render "admin/sites/new"
      response.should have_tag("input[name=?]", 'section[title]')
    end
    
    it "renders radio buttons for setting the root section type" do
      render "admin/sites/new"
      response.should have_tag("input[type=?][name=?]", 'radio', 'section[type]')
    end
  end
  
  describe "the :edit view" do
    before :each do
      assigns[:site] = @site
      template.stub_render :partial => 'form', :locals => hash_including(:site => @site)
    end
    
    it "renders the site form partial" do
      assigns[:site] = @site
      template.expect_render :partial => 'form', :locals => hash_including(:site => @site)
      render "admin/sites/edit"
    end
    
    it "has a form tag that PUTs to member_path" do
      render "admin/sites/edit"
      response.should have_tag('form[action=?]', @member_path) do |form|
        form.should have_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
  end
end