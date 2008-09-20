require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::CachedPages:" do
  include SpecViewHelper

  before :each do
    scenario :cached_pages
    assigns[:site] = @site = stub_site

    set_resource_paths :cached_page, '/admin/sites/1/'

    template.stub!(:admin_cached_pages_path).and_return(@collection_path)
    template.stub!(:admin_cached_page_path).and_return(@member_path)

    template.stub!(:pluralize_str)
    template.stub!(:will_paginate)
  end

  describe "the :index view" do
    before :each do
      @cached_pages.stub!(:total_entries).and_return 20
      assigns[:cached_pages] = @cached_pages
      template.stub_render hash_including(:partial => 'cached_page')
    end

    it "should display a list of cached pages" do
      render "admin/cached_pages/index"
      response.should have_tag('table[id=?]', 'cached_pages')
    end

    it "should render the cached_page partial with the cached_pages collection" do
      template.stub_render hash_including(:partial => 'cached_page', :collection => @cached_pages)
      render "admin/cached_pages/index"
    end
  end

  describe "the cached_page partial" do
    before :each do
      template.stub!(:cached_page).and_return(@cached_page)
      template.stub!(:link_to_remote)
      template.stub!(:cached_page_date)
    end

    it "should render a link_to_remote to delete the cached_page" do
      template.should_receive(:link_to_remote).with 'Clear', hash_including(:url => @member_path)
      render "admin/cached_pages/_cached_page"
    end
  end
end