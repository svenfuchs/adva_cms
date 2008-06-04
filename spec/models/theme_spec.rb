require File.dirname(__FILE__) + '/../spec_helper'

describe Theme do
  @@about = { 'author' => 'Sven Fuchs',
              'homepage' => 'http://www.artweb-design.de',
              'version' => '0.1', 
              'summary' => 'awesome' }
  
  before :each do
    File.stub!(:directory?).and_return true
  end
  
  describe "finders called without subdir" do    
    it "should find and return an installed theme" do
      expect_find_one_theme_with 'theme_1'
    end
  
    it "should find and return all installed themes" do
      expect_find_all_themes_with
    end
  end
  
  describe "finders called without subdir" do      
    it "should find and return an installed theme" do
      expect_find_one_theme_with 'theme_1', '/subdir/'
    end
  
    it "should find and return all installed themes" do
      expect_find_all_themes_with 'subdir/'
    end
  end
  
  describe "#create" do
    before :each do
      @path = "#{Theme.base_dir}/themes/site-1/a_theme"
      @attrs = @@about.clone.merge('path' => @path)
      FileUtils.stub!(:mkdir_p)
      ::File.stub!(:open)
    end
    
    it "should create the theme directory" do
      FileUtils.should_receive(:mkdir_p).with(@path)
      Theme.create! @attrs.merge(:name => 'theme-1')
    end

    it "should save the about.yml file" do
      ::File.should_receive(:open).with(Pathname.new("#{@path}/about.yml"), 'wb')
      Theme.create! @attrs.merge(:name => 'theme-1')
    end
  end
  
  describe "about" do
    before :each do
      path = Pathname.new("#{RAILS_ROOT}/themes/theme_1")
      Pathname.stub!(:new).and_return path
      path.stub!(:+).and_return path
      path.stub!(:exist?).and_return true
      YAML.stub!(:load_file).and_return @@about.clone
      @theme = call_find(:find, 'theme_1')
    end
    
    it "should load about" do
      @theme.send(:about).should == @@about
    end
    
    ['author', 'homepage', 'version', 'summary'].each do |property|
      it "should return property #{property}" do
        @theme.send(property).should == @@about[property]
      end
    end
    
    it "should return 'unknown' as an author_link when no homepage and no author is set" do
      @theme.send(:about).delete 'homepage'
      @theme.send(:about).delete 'author'
      @theme.author_link.should == 'unknown'
    end
    
    it "should return author as an author_link when no homepage is set" do
      @theme.send(:about).delete 'homepage'
      @theme.author_link.should == @@about['author']
    end
    
    it "should return an html link as an author_link when homepage is set" do
      @theme.author_link.should == %(<a href="#{@@about['homepage']}">#{@@about['author']}</a>)
    end
  end
  
  def expect_find_one_theme_with(id, subdir = nil)
    theme = call_find(:find, id, subdir)
    theme.should be_instance_of(Theme)
    theme.id.should == 'theme_1'    
  end    
  
  def expect_find_all_themes_with(subdir = nil)
    themes = call_find(:find, :all, subdir)
    themes.should be_instance_of(Array)
    themes.first.should be_instance_of(Theme)
    themes.map(&:id).should == ['theme_1', 'theme_2']
  end    
  
  def call_find(finder, *args)    
    subdir = args.size > 1 ? args.last : nil
    Dir.stub!(:glob).and_return [1, 2].collect{|ix| "#{RAILS_ROOT}/themes/#{subdir}theme_#{ix}" }
    t = Theme.send finder, *args 
  end    
end

class Something < ActiveRecord::Base
  self.abstract_class = true
  acts_as_themed :default => 'funky'
  class << self
    def columns
      @columns ||= []
    end    
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      reset_column_information
    end
  end  
end

describe "acts_as_themed" do   
  
  before :each do
    @something = Something.new
    @something.stub!(:id).and_return 1
    @something.stub!(:theme_names).and_return ['theme-1']
  end
  
  it "should validate with a valid theme name" do
    @something.should be_valid
  end
  
  it "should forbid forward slashes in the theme_name" do
    @something.stub!(:theme_names).and_return ['etc/whatever']
    @something.should_not be_valid
  end
  
  it "should forbid backward slashes in the theme_name" do
    @something.stub!(:theme_names).and_return ['etc\whatever']
    @something.should_not be_valid
  end
  
  it "should prefix theme_name with theme_dir" do
    @something.theme_paths.should == ['something-1/theme-1']
  end
  
  it "should return 'funky' as default theme_name when no theme name set" do
    @something.stub!(:theme_names).and_return []
    @something.theme_paths.should == ['something-1/funky']
  end
  
  it "should delegate find through proxy class to Theme, passing theme_dir" do
    Theme.should_receive(:find).with(:all, "something-1/")
    @something.themes.find(:all)
  end
  
  it "should call Theme to find the current_theme" do
    Theme.should_receive(:find).with(['theme-1'], "something-1/")
    @something.current_themes
  end
  
  it "should return '[theme base_dir]/something-1' as a themes_path" do
    @something.themes_dir.should == "#{Theme.base_dir}/something-1/"
  end
end
