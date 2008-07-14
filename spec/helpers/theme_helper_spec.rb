require File.dirname(__FILE__) + '/../spec_helper'

describe ThemeAssetTagHelper do
  include ThemeAssetTagHelper
  
  before :each do
    theme = mock(Theme)
    theme.stub!(:id).and_return('theme-1')
    theme.stub!(:local_path).and_return('site-1/theme-1')
    @controller.stub!(:current_themes).and_return [theme]
    
    @theme_path = "theme-1/something"
  end
  
  def controller
    @controller
  end
  
  describe "#add_theme_path" do  
    it "should add the theme path to a source" do
      add_theme_path('theme-1', 'something').should == @theme_path
    end
  end
  
  describe "#add_theme_paths" do  
    it "should add the theme path to a single source" do
      add_theme_paths('theme-1', ['something']).should == [@theme_path]
    end
    
    it "should add the theme path to multiple sources and leave options untouched" do
      add_theme_paths('theme-1', ['something', 'else', {:foo => :bar}]).should == [@theme_path, 'theme-1/else', {:foo => :bar}]
    end
  end
  
  describe "#theme_image_tag" do  
    it "should call add_theme_path for an image tag" do
      should_receive(:add_theme_path).with('theme-1', 'something').and_return @theme_path
      theme_image_tag('theme-1', 'something')
    end
  
    it "should return an image tag with the theme path added to src" do
      theme_image_tag('theme-1', 'something').should have_tag('img', :src => /^#{@theme_path}/)
    end
  end
  
  describe "#theme_javascript_include_tag" do  
    it "should call add_theme_path for a javascript include tag" do
      should_receive(:add_theme_path).with('theme-1', 'something').and_return @theme_path
      theme_javascript_include_tag('theme-1', 'something')
    end
  
    it "should return an javascript include tag with the theme path added to source" do
      theme_javascript_include_tag('theme-1', 'something').should have_tag('script', :source => /^#{@theme_path}/)
    end
  end
  
  describe "#theme_stylesheet_link_tag" do  
    it "should call add_theme_path for a stylesheet link tag" do
      should_receive(:add_theme_path).with('theme-1', 'something').and_return @theme_path
      theme_stylesheet_link_tag('theme-1', 'something')
    end
  
    it "should return a stylesheet link tag with the theme path added to link" do
      theme_stylesheet_link_tag('theme-1', 'something').should have_tag('link', :href => /^#{@theme_path}/)
    end
  end
end