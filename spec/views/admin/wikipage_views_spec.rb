require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Wikipages:" do
  include SpecViewHelper

  before :each do
    scenario :wiki_with_wikipages
    assigns[:section] = @section
    assigns[:site] = @site
    assigns[:categories] = @categories = [@category, @category]

    set_resource_paths :wikipage, '/admin/sites/1/sections/1/'

    template.stub!(:admin_wikipages_path).and_return(@collection_path)
    template.stub!(:admin_wikipage_path).and_return(@member_path)
    template.stub!(:new_admin_wikipage_path).and_return @new_member_path
    template.stub!(:edit_admin_wikipage_path).and_return(@edit_member_path)

    template.stub!(:will_paginate)
    template.stub!(:time_ago_in_words_with_microformat).and_return 'Once upon a time ...'
  end

  describe "the index view" do
    before :each do
      assigns[:wikipages] = @wikipages
    end

    it "should display a list of wikipages" do
      template.stub_render :partial => 'wikipage', :collection => @wikipages
      render "admin/wikipages/index"
      response.should have_tag('table[id=wikipages]')
    end

    it "should render the wikipage partial" do
      template.expect_render :partial => 'wikipage', :collection => @wikipages
      render "admin/wikipages/index"
    end
  end
end