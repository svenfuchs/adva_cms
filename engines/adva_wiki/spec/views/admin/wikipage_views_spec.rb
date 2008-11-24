require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Wikipages:" do
  include SpecViewHelper

  before :each do
    stub_scenario :wiki_with_wikipages
    assigns[:section] = @section
    assigns[:site] = @site
    assigns[:categories] = @categories = [@category, @category]

    set_resource_paths :wikipage, '/admin/sites/1/sections/1/'

    template.stub!(:admin_wikipages_path).and_return(@collection_path)
    template.stub!(:admin_wikipage_path).and_return(@member_path)
    template.stub!(:new_admin_wikipage_path).and_return @new_member_path
    template.stub!(:edit_admin_wikipage_path).and_return(@edit_member_path)

    template.stub!(:render).with hash_including(:partial => 'options')
    template.stub!(:render).with hash_including(:partial => 'categories/checkboxes')
    template.stub!(:render).with hash_including(:partial => 'admin/assets/widget/widget')

    template.stub!(:will_paginate)
    template.extend ContentHelper
    template.extend BaseHelper
  end

  describe "the index view" do
    before :each do
      assigns[:wikipages] = @wikipages
    end
    
    it "should have a link to create wikipage form to the sidebar" do
      template.stub!(:render).with :partial => 'wikipage', :collection => @wikipages
      render "admin/wikipages/index"
      content_for(:sidebar).should have_tag('a[href=?]', @new_member_path)
    end

    it "should display a list of wikipages" do
      template.stub!(:render).with :partial => 'wikipage', :collection => @wikipages
      render "admin/wikipages/index"
      response.should have_tag('table[id=wikipages]')
    end

    it "should render the wikipage partial" do
      template.should_receive(:render).with :partial => 'wikipage', :collection => @wikipages
      render "admin/wikipages/index"
    end
    
    describe "without any wikipages" do
      before :each do
        assigns[:wikipages] = []
      end
      
      it "should have a link to create wikipage form" do
        render "admin/wikipages/index"
        response.should have_tag('a[href=?]', @new_member_path)
      end
    end
  end

  describe "the new view" do
    before :each do
      assigns[:wikipage] = @wikipage
    end

    it "should render the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/wikipages/new"
    end
  end

  describe "the edit view" do
    before :each do
      assigns[:wikipage] = @wikipage
    end
  
    it "should render the form partial" do
      template.stub! :link_to
      template.stub! :content_url
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/wikipages/edit"
    end
  end

  describe "the form partial" do
    before :each do
      assigns[:wikipage] = @wikipage
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:wikipage, @wikipage, template, {}, nil)
    end

    it "should render the options partial to the sidebar" do
      template.should_receive(:render).with hash_including(:partial => 'options')
      render "admin/wikipages/_form"
    end

    it "should render the wikipage form fields" do
      render "admin/wikipages/_form"
      response.should have_tag('input[name=?]', 'wikipage[title]')
      response.should have_tag('textarea[name=?]', 'wikipage[body]')
    end
  end

  describe "the options partial" do
    before :each do
      assigns[:wikipage] = @wikipage
      
      @wikipage.stub!(:assets).and_return []
      @wikipage.stub!(:filter).and_return nil
      @site.stub!(:assets).and_return mock('assets_proxy', :recent => [])
      template.stub!(:bucket_assets)

      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:wikipage, @wikipage, template, {}, nil)
      template.stub!(:filter_options).and_return []
      template.stub!(:comment_expiration_options).and_return []
      template.stub!(:author_options).and_return([["current user"], [1]])
      template.stub!(:author_preselect).and_return 1
    end
    
    it "should render the categories/checkboxes partial" do
      template.should_receive(:render).with hash_including(:partial => 'categories/checkboxes')
      render "admin/wikipages/_options"
    end
    
    it "should render the assets/widget/widget partial" do
      template.should_receive(:render).with hash_including(:partial => 'admin/assets/widget/widget')
      render "admin/wikipages/_options"
    end

    it "should have the selectbox for selecting an author for an article" do
      render "admin/wikipages/_options"
      response.should have_tag('select[id=?]', 'wikipage_author')
    end
    
    describe "when wikipage has multiple versions" do
      it "should have links for handling version control" do
        template.should_receive(:wiki_version_links)
        render "admin/wikipages/_options"
      end
    end
  end
  
  describe "the wikipages partial" do
    before :each do
      template.stub!(:admin_comments_path)
      template.stub!(:strftime)
      template.stub!(:wikipage).and_return(@wikipage)
      template.stub! :link_to
    end
    
    it "should render partial" do
      render "admin/wikipages/_wikipage"
      response.should be_success
    end
    
    it "should display the version of wikipage" do
      @wikipage.should_receive(:version)
      render "admin/wikipages/_wikipage"
    end
    
    it "should display the date of latest update of wikipage" do
      @wikipage.should_receive(:updated_at).and_return Date.today
      render "admin/wikipages/_wikipage"
    end
    
    it "should display a link to the author of wikipage" do
      @wikipage.should_receive(:author_link)
      render "admin/wikipages/_wikipage"
    end
    
    it "should check if wikipage has comments" do
      @wikipage.comments.should_receive(:size).and_return 0
      render "admin/wikipages/_wikipage"
    end
  end
end