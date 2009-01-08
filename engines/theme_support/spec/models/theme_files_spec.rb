require File.dirname(__FILE__) + '/../spec_helper'

describe Theme::File do
  include SpecThemeHelper

  before :each do
    Theme.stub!(:root_dir).and_return('/tmp')
    Theme.stub!(:base_dir).and_return('/tmp/themes')
    setup_theme_mocks

    @theme = Theme.new :path => '/tmp/themes/site-1/theme-1/'

    @name = 'image-1.png'
    @localpath = "images/#{@name}"
    @fullpath = "/tmp/themes/site-1/theme-1/#{@localpath}"
    @path = "/images/themes/theme-1/#{@name}"
  end

  describe "preview.png" do
    before :each do
      preview_path = Pathname.new "#{@theme.path}images/preview.png"
      Pathname.stub!(:glob).and_return([preview_path]) # + @asset_paths + @template_paths
    end

    it "should have the correct fullpath set" do
      @theme.preview.fullpath.to_s.should == "#{@theme.path}images/preview.png"
    end

    it "should have the correct localpath set" do
      @theme.preview.localpath.to_s.should == "images/preview.png"
    end

    it "should have the correct path set" do
      @theme.preview.path.to_s.should == "/images/themes/theme-1/preview.png"
    end
  end

  describe "default_preview" do
    before :each do
      @preview = Theme::Other.default_preview(@theme, '[rails_root]/path/to/preview/preview.png')
    end
  
    it "should have the correct fullpath set" do
      @preview.fullpath.to_s.should == "[rails_root]/path/to/preview/preview.png"
    end
  
    it "should have the correct localpath set" do
      @preview.localpath.to_s.should == "preview.png"
    end
  
    it "should have the correct path set" do
      # @preview.path.to_s.should == "/images/themes/site-1/theme-1/preview.png"
      @preview.path.to_s.should == "/images/themes/theme-1/preview.png"
    end
  end
  
  ['fullpath', 'localpath'].each do |key|
    describe "when created using a #{key}" do
      before :each do
        @asset = Theme::Asset.new @theme, instance_variable_get(:"@#{key}")
      end
  
      it "should have correct name set" do
        @asset.basename.to_s.should == @name
      end
  
      it "should have correct localpath set" do
        @asset.localpath.to_s.should == @localpath
      end
  
      it "should have correct path set" do
        @asset.path.to_s.should == @path
      end
  
      it "should have correct fullpath set" do
        @asset.fullpath.to_s.should == @fullpath
      end
    end
  end
  
  describe "when created using a localpath with subdirs" do
    before :each do
      subdirs = "foo/bar"
      @localpath = "images/#{subdirs}/#{@name}"
      @fullpath = "/tmp/themes/site-1/theme-1/images/#{subdirs}/#{@name}"
      # @path = "/images/themes/site-1/theme-1/#{subdirs}/#{@name}"
      @path = "/images/themes/theme-1/#{subdirs}/#{@name}"
      @asset = Theme::Asset.new @theme, @localpath
    end
  
    it "should have correct name set" do
      @asset.basename.to_s.should == @name
    end
  
    it "should have correct localpath set" do
      @asset.localpath.to_s.should == @localpath
    end
  
    it "should have correct path set" do
      @asset.path.to_s.should == @path
    end
  
    it "should have correct fullpath set" do
      @asset.fullpath.to_s.should == @fullpath
    end
  end
  
  it "should precede path with a leading slash" do
    @asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    @asset.path.to_s[0, 1].should == '/'
  end
  
  it "should generate an id by replacing slashes and dots through dashes" do
    @asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    @asset.id.should == "images-foo-bar-image-1-png"
  end
  
  it "should deliberately ignore leading slashes to filename" do
    Theme::Asset.new(@theme, '/image-1.png').should == Theme::Asset.new(@theme, 'image-1.png')
  end
  
  it "should deliberately ignore leading slashes to localpath" do
    Theme::Asset.new(@theme, '/something/image-1.png').should == Theme::Asset.new(@theme, 'something/image-1.png')
  end
  
  %w(js css png jpg jpeg gif swf ico).each do |ext|
    it "should recognize a file with an .#{ext} extension as a valid asset" do
      Theme::Asset.new(@theme, "images/path/to/something.#{ext}").valid?.should be_true
    end
  end
  
  %w(png jpg jpeg gif swf ico).each do |ext|
    it "should recognize 'images/something.#{ext}' as an non-text filename" do
      Theme::Asset.new(@theme, "images/path/to/something.#{ext}").text?.should be_false
    end
  end
  
  %w(stylesheets/something.css javascripts/something.js).each do |filename|
    it "should recognize '#{filename}' as a text filename" do
      Theme::Asset.new(@theme, filename).text?.should be_true
    end
  end
end

describe Theme::Files do
  include SpecThemeHelper

  before :each do
    Theme.stub!(:root_dir).and_return('/path/to')
    Theme.stub!(:base_dir).and_return('/path/to/themes')
    setup_theme_mocks
  end

  it "should qualify a Windows path as a valid path" do
    windows_path = 'C:\Dokumente\Eigene Dateien\Ein Dateiname mit Leerzeichen.doc'
    Theme::Path.valid_path?(windows_path).should be_true
  end

  describe "Files collection proxy" do
    it "should search assets collections when called find" do
      @theme.files.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
    end

    it "should search templates collections when called find" do
      @theme.files.find('templates-layouts-layout-liquid').localpath.to_s.should == "templates/layouts/layout.liquid"
    end
  end

  describe "Assets collection" do
    it "should return an Theme::Asset when called find" do
      @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
    end

    it "should return an Theme::Asset with the correct path when called find" do
      @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
    end

    it "should find the file javascripts/something.js with the id 'javascripts-something-js'" do
      @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
    end

    it "should only accept asset files" do
      @theme.assets.map(&:fullpath).should == @asset_paths
    end
  end

  describe "Templates collection" do
    %w(liquid html.haml html.erb).each do |extension|
      it "should recognize a file with an .#{extension} extension as a valid template" do
        Theme::Template.new(@theme, "templates/path/to/something.#{extension}").valid?.should be_true
      end
    end

    it "should only accept template files" do
      @theme.templates.map(&:fullpath).should == @template_paths
    end
  end
end