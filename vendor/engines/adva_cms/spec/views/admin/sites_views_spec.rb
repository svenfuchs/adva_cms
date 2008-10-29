require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Sites Views:" do
  include SpecViewHelper

  before :each do
    @site = stub_site
    @sites = [@site, @site]

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

    it "displays a link to a site's overview" do
      assigns[:sites] = @sites
      render "admin/sites/index"
      response.should have_tag('a[href=?]', admin_site_path(@sites.first), @sites.first.name)
    end

    it "displays a link to delete the site" do
      assigns[:sites] = @sites
      render "admin/sites/index"
      response.should have_tag('a[href=?][class=?]', admin_site_path(@sites.first), 'delete', 'delete')
    end

    it "displays a link to a site's settings" do
      assigns[:sites] = @sites
      render "admin/sites/index"
      response.should have_tag('a[href=?][class=?]', edit_admin_site_path(@sites.first), 'edit', 'settings')
    end

    it "displays a link to the site's frontend" do
      assigns[:sites] = @sites
      render "admin/sites/index"
      response.should have_tag('a[href=?][class=?]', "http://#{@sites.first.host}", 'view')
    end
  end

  describe "the :show view" do
    before :each do
      assigns[:site] = @site
      @site.sections.stub!(:roots).and_return []
      template.stub_render hash_including(:partial => 'sections')
      template.stub_render hash_including(:partial => 'admin/activities/activities')
      template.stub_render hash_including(:partial => 'user_activity')
      template.stub_render hash_including(:partial => 'unapproved_comments')
    end

    it "renders sections partial" do
      template.expect_render hash_including(:partial => 'sections')
      render "admin/sites/show"
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
  
  describe "the section partial" do
    before :each do
      @section, @blog, @wiki = stub_section, stub_blog, stub_wiki
      @section.stub!(:children).and_return [@blog, @wiki]
      
      assigns[:site] = stub_site
      template.stub!(:sections).and_return [@section]
    end
    
    it "renders a nested list of site sections" do
      render "admin/sites/_sections"
      response.should have_tag('ul li', /#{@section.title}/) do
        with_tag('ul li', @blog.title)
        with_tag('ul li', @wiki.title)
      end
    end
  end

  describe "the form partial" do
    before :each do
      @site.stub!(:spam_options).and_return Site.new.spam_options
      template.stub!(:site).and_return @site
      template.stub!(:filter_options).and_return []
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:section, @section, template, {}, nil)
    end

    it "renders checkboxes for selecting the active spam filters" do
      render "admin/sites/_form"
      SpamEngine::Filter.names.each do |name|
        next if name == 'Default'
        response.should have_tag('input[type=?][name=?][value=?]', 'checkbox', 'site[spam_options][filters][]', name)
      end
    end

    it "renders the settings partials for each registered spam filter" do
      SpamEngine::Filter.names.each do |name|
        template.expect_render hash_including(:partial => "spam/#{name.downcase}_settings")
      end
      render "admin/sites/_form"
    end
  end
end