require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ThemeTest < ActiveSupport::TestCase
  include ThemeTestHelper

  def setup
    super
    @site = Site.first
    @theme = Theme.find_by_name 'a theme'
    @theme_params = { :name     => 'another theme',
                      :version  => '1.0.0',
                      :homepage => 'http://homepage.org',
                      :author   => 'author',
                      :summary  => 'summary' }
  end

  # ASSOCIATIONS

  test "belongs to a site" do
    @theme.should belong_to(:site)
  end

  test "has many templates" do
    @theme.should have_many(:templates)
  end

  test "the templates association only finds templates" do
    template = uploaded_template
    @theme.templates.should == [template]
  end

  test "has many images" do
    @theme.should have_many(:images)
  end

  test "the assets association only finds images" do
    image = uploaded_image
    @theme.images.should == [image]
  end

  test "has many javascripts" do
    @theme.should have_many(:javascripts)
  end

  test "the assets association only finds javascripts" do
    javascript = uploaded_javascript
    @theme.javascripts.should == [javascript]
  end

  test "has many stylesheets" do
    @theme.should have_many(:stylesheets)
  end

  test "the assets association only finds stylesheets" do
    stylesheet = uploaded_stylesheet
    @theme.stylesheets.should == [stylesheet]
  end

  test "has one preview" do
    @theme.should have_one(:preview)
  end

  test "the preview association finds a preview" do
    preview = uploaded_preview
    @theme.preview(true).should == preview
  end

  # VALIDATIONS

  test "validates the presence of a name" do
    @theme.should validate_presence_of(:name)
  end

  # CALLBACKS

  test "creates an empty preview after create" do
    theme = @site.themes.create! @theme_params
    theme.preview.should_not be_nil
  end

  # CLASS METHODS

  test "imports a zip theme" do
    theme_file = theme_fixture

    assert_difference '@site.themes.size', +1 do
      @site.themes.import(theme_file)
    end
    assert_equal 5, @site.themes.last.files.size
  end

  test "valid_theme? returns true if theme folder contains one of the theme folders: images, templates, stylesheets or javascripts" do
    assert Theme.valid_theme?(theme_fixture)
  end

  test "valid_theme? returns false if theme folder does not contain one of the theme folders: images, templates, stylesheets or javascripts" do
    assert ! Theme.valid_theme?(invalid_theme_fixture)
  end

  # INSTANCE METHODS
  test "returns about hash" do
    about_hash =  { "name" => "a theme", "author" => "author", "version" => "1.0.0",
                    "homepage" => "http://homepage.org", "summary" => "summary" }
    @theme.about.should == about_hash
  end

  test "creates a file when exporting a theme" do
    theme = @site.themes.create!(:name => 'export-theme')
    zip_path = theme.export
    zip_path.should be_file
  end

  test "created ZIP file includes all theme files" do
    theme = @site.themes.create!(:name => 'export-theme')
    uploaded_stylesheet(theme)
    uploaded_javascript(theme)
    uploaded_image(theme)
    uploaded_template(theme)

    zip_path = theme.export
    zip_file = Zip::ZipFile.new(zip_path)

    theme.files.each do |file|
      zip_file.entries.map(&:name).should include(file.base_path)
    end
  end

  test "activate! activates the theme" do
    @theme.activate!
    @theme.should be_active
  end

  test "deactivate! deactivates the theme" do
    @theme.update_attributes(:active => true)
    @theme.deactivate!
    @theme.should_not be_active
  end

  test "find_theme_root finds the root directory of the theme from deeply nested zip archive" do
    assert_equal 'deep_nesting/theme/', Theme.send(:find_theme_root, deeply_nested_theme_fixture)
  end

  test "find_theme_root works with nested templates directory" do
    # fix that find_theme_root does not result in incorrect foo/bar/ root
    assert_equal '', Theme.send(:find_theme_root, theme_fixture)
  end

  test "strip_path strips the given folder structure out of path" do
    assert_equal 'images/image.jpg', Theme.send(:strip_path, 'deep_nesting/theme/images/image.jpg', 'deep_nesting/theme/')
  end

  test "strip_path strips only from the start" do
    assert_equal 'images/foo/bar/image.jpg', Theme.send(:strip_path, 'foo/bar/images/foo/bar/image.jpg', 'foo/bar/')
  end

  # cached_files

  test "#cached_files returns an array of cached files" do
    setup_theme_with_cached_files(@theme)
    assert_equal @theme.cached_files.sort, ["#{@theme.path}/javascripts/cached_javascript.js",
                                            "#{@theme.path}/javascripts/folder/cached/folder",
                                            "#{@theme.path}/javascripts/folder/cached/folder/some_javascript.css",
                                            "#{@theme.path}/stylesheets/cached_stylesheet.css"].sort
  end

  # clear_asset_cache!

  test "#clear_asset_cache! removes the cached folders and cached_ files from theme" do
    setup_theme_with_cached_files(@theme)
    @theme.clear_asset_cache!
    theme_files = Dir.glob("#{@theme.path}/**/*")

    theme_files.should_not include("#{@theme.path}/javascripts/cached_javascript.js")
    theme_files.should_not include("#{@theme.path}/stylesheets/cached_stylesheet.css")
    theme_files.should_not include("#{@theme.path}/javascripts/folder/cached/")
  end

  def setup_theme_with_cached_files(theme = theme)
    uploaded_template(theme)
    uploaded_stylesheet(theme)
    uploaded_javascript(theme)
    uploaded_image(theme)
    FileUtils.touch(theme.path + '/stylesheets/cached_stylesheet.css')
    FileUtils.touch(theme.path + '/javascripts/cached_javascript.js')
    FileUtils.mkdir_p(theme.path + '/javascripts/folder/cached/folder')
    FileUtils.touch(theme.path + '/javascripts/folder/cached/folder/some_javascript.css')
  end
end