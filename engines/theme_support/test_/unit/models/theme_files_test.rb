require File.dirname(__FILE__) + '/../../test_helper'
module ThemeMocks
end

class ThemeFileTest < ActiveSupport::TestCase
  def setup
    super
    Theme.root_dir = '/tmp' # FIXME ... this really should happen globally for all tests
    setup_theme_mocks

    @theme = Theme.new :path => '/tmp/themes/site-1/theme-1/'
    @localpath = "images/image-1.png"
    @fullpath = "/tmp/themes/site-1/theme-1/images/image-1.png"
  end
  
  ['fullpath', 'localpath'].each do |key|
    test "when created using a #{key} it has correct name set" do
      asset = Theme::Asset.new @theme, instance_variable_get(:"@#{key}")
      asset.basename.to_s.should == 'image-1.png'
    end

    test "when created using a #{key} it has correct localpath set" do
      asset = Theme::Asset.new @theme, instance_variable_get(:"@#{key}")
      asset.localpath.to_s.should == 'images/image-1.png'
    end

    test "when created using a #{key} it has correct path set" do
      asset = Theme::Asset.new @theme, instance_variable_get(:"@#{key}")
      asset.path.to_s.should == "/images/themes/theme-1/image-1.png"
    end

    test "when created using a #{key} it has correct fullpath set" do
      asset = Theme::Asset.new @theme, instance_variable_get(:"@#{key}")
      asset.fullpath.to_s.should == "/tmp/themes/site-1/theme-1/images/image-1.png"
    end
  end
  
  test "when created using a localpath with subdirs it has correct name set" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.basename.to_s.should == 'image-1.png'
  end

  test "when created using a localpath with subdirs it has correct localpath set" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.localpath.to_s.should == "images/foo/bar/image-1.png"
  end

  test "when created using a localpath with subdirs it has correct path set" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.path.to_s.should == "/images/themes/theme-1/foo/bar/image-1.png"
  end

  test "when created using a localpath with subdirs it has correct fullpath set" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.fullpath.to_s.should == "/tmp/themes/site-1/theme-1/images/foo/bar/image-1.png"
  end
  
  test "prepends a leading slash to the path" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.path.to_s[0, 1].should == '/'
  end
  
  test "generates an id by replacing slashes and dots through dashes" do
    asset = Theme::Asset.new @theme, "images/foo/bar/image-1.png"
    asset.id.should == "images-foo-bar-image-1-png"
  end
  
  test "ignores leading slashes to filename" do
    Theme::Asset.new(@theme, '/image-1.png').should == Theme::Asset.new(@theme, 'image-1.png')
  end
  
  test "ignores leading slashes to localpath" do
    Theme::Asset.new(@theme, '/something/image-1.png').should == Theme::Asset.new(@theme, 'something/image-1.png')
  end
  
  %w(js css png jpg jpeg gif swf ico).each do |ext|
    test "recognizes a file with an .#{ext} extension as a valid asset" do
      Theme::Asset.new(@theme, "images/path/to/something.#{ext}").valid?.should be_true
    end
  end
  
  %w(png jpg jpeg gif swf ico).each do |ext|
    test "recognizes 'images/something.#{ext}' as a non-text filename" do
      Theme::Asset.new(@theme, "images/path/to/something.#{ext}").text?.should be_false
    end
  end
  
  %w(stylesheets/something.css javascripts/something.js).each do |filename|
    test "recognizes '#{filename}' as a text filename" do
      Theme::Asset.new(@theme, filename).text?.should be_true
    end
  end
  
  test "qualifies a Windows path as a valid path" do
    windows_path = 'C:\Dokumente\Eigene Dateien\Ein Dateiname mit Leerzeichen.doc'
    Theme::Path.valid_path?(windows_path).should be_true
  end
  
  # FIXME make these pass

  # test "the files collection proxy searches assets collections when called find" do
  #   @theme.files.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
  # end
  
  # test "the files collection proxy searches templates collections when called find" do
  #   @theme.files.find('templates-layouts-layout-liquid').localpath.to_s.should == "templates/layouts/layout.liquid"
  # end
  
  # test "the assets collection returns an Theme::Asset when called find" do
  #   @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
  # end
  
  # test "the assets collection returns an Theme::Asset with the correct path when called find" do
  #   @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
  # end
  
  # test "the assets collection finds the file javascripts/something.js with the id 'javascripts-something-js'" do
  #   @theme.assets.find('javascripts-something-js').localpath.to_s.should == "javascripts/something.js"
  # end

  # test "the assets collection only accepts asset files" do
  #   @theme.assets.map(&:fullpath).should == @asset_paths
  # end
  
  %w(liquid html.haml html.erb).each do |extension|
    test "the templates collection recognizes a file with an .#{extension} extension as a valid template" do
      Theme::Template.new(@theme, "templates/path/to/something.#{extension}").valid?.should be_true
    end
  end
  
  # test "the templates collection only accepts template files" do
  #   @theme.templates.map(&:fullpath).should == @template_paths
  # end

  
  protected
  
    def setup_theme_mocks
      @image_exts     = %w(png jpg jpeg gif swf ico)
      @image_paths    = @image_exts.collect{|ext| "images/something.#{ext}"}
      @asset_paths    = %w(stylesheets/something.css javascripts/something.js) + @image_paths
      @other_paths    = %w(preview.png)
      @template_paths = %w(templates/layouts/layout.liquid templates/template.html.erb)

      @theme = Theme.new :path => '/path/to/themes/site-1/theme-1/'

      [@image_paths, @asset_paths, @other_paths, @template_paths].each do |paths|
        paths.map!{|path| Pathname.new "#{@theme.path}#{path}" }
      end
      stub(Pathname).glob(anything).returns(@asset_paths + @template_paths)

      @file = @theme.files.find('templates-layouts-layout-liquid')
    end
  
end