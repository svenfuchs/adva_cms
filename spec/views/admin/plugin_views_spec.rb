require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Plugins:" do
  include SpecViewHelper
  
  before :each do
    assigns[:site] = @site = stub_site
    
    @plugin = Engines.plugins[:test_plugin].clone
    @plugin.owner = @site
    @plugins = Engines::Plugin::List.new([@plugin])
    
    set_resource_paths :plugin, '/admin/sites/1/'

    template.stub!(:admin_plugins_path).and_return(@collection_path)
    template.stub!(:admin_plugin_path).and_return(@member_path)

    template.stub!(:pluralize_str)
    template.stub!(:will_paginate)
  end
  
  describe "the :index view" do
    before :each do
      assigns[:plugins] = @plugins
      template.stub_render hash_including(:partial => 'plugin')
    end

    it "should display a list of cached pages" do
      render "admin/plugins/index"
      response.should have_tag('table[id=?]', 'plugins')
    end
    
    it "should render the plugin partial with the plugins collection" do
      template.expect_render hash_including(:partial => 'plugin', :collection => @plugins)
      render "admin/plugins/index"
    end   
  end
  
  describe "the :show view" do
    before :each do
      assigns[:plugin] = @plugin
      template.stub_render hash_including(:partial => 'form')
    end
    
    it "should display author information for the plugin" do
      render "admin/plugins/show"
      response[:sidebar].should have_text(/#{@plugin.about['author']}/)
    end
    
    it "should display homepage information for the plugin" do
      render "admin/plugins/show"
      response[:sidebar].should have_text(/#{@plugin.about['homepage']}/)
    end
    
    it "should display a summary for the plugin" do
      render "admin/plugins/show"
      response[:sidebar].should have_text(/#{@plugin.about['summary']}/)
    end
    
    it "should display a description for the plugin" do
      render "admin/plugins/show"
      response.should have_text(/#{@plugin.about['description']}/)
    end
    
    it "should render the form partial" do
      template.expect_render hash_including(:partial => 'form')
      render "admin/plugins/show"
    end
  end
  
  describe "the action_nav partial" do
    before :each do
      assigns[:plugin] = @plugin
    end
    
    it "should display a link to the index view" do
      render "admin/plugins/_action_nav"
      response[:action_nav].should have_tag('a[href=?]', admin_plugins_path(@site), 'Plugins')
    end

    it "should display a link to restore the default values" do
      render "admin/plugins/_action_nav"
      response[:action_nav].should have_tag('a[href=?]', admin_plugin_path(@site, @plugin), 'Restore Defaults')
    end
  end
  
  describe "the form partial" do
    before :each do
      assigns[:plugin] = @plugin
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:plugin, @plugin, template, {}, nil)
    end
    
    it "should render a string field for the string option" do
      render "admin/plugins/_form"
      response.should have_tag('input[name=?][value=?]', 'plugin[string]', 'default string')
    end

    it "should render a text field for the text option" do
      render "admin/plugins/_form"
      response.should have_tag('textarea[name=?]', 'plugin[text]', 'default text')
    end
  end
end