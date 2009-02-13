require File.dirname(__FILE__) + '/../../test_helper'

class ThemeFileTest < ActiveSupport::TestCase
  include ThemeTestHelper

  def setup
    super
    @theme = Theme.find_by_name 'a theme'
  end

  def expect_valid_file(file, type, path)
    file.should be_kind_of(type)
    file.should be_valid
    file.path.should be_file
    file.path.should == path
  end

  test "instantiates a valid Theme::Preview for a file images/preview.png" do
    expect_valid_file(uploaded_preview, Theme::Preview, "#{@theme.path}/images/preview.png")
  end

  test "instantiates a valid Theme::Template for a valid template extension" do
    expect_valid_file(uploaded_template, Theme::Template, "#{@theme.path}/templates/foo/bar/template.html.erb")
  end

  test "instantiates a valid Theme::Image for a valid asset extension" do
    expect_valid_file(uploaded_image, Theme::Image, "#{@theme.path}/images/rails.png")
  end

  test "instantiates a valid Theme::Javascript for a valid asset extension" do
    expect_valid_file(uploaded_javascript, Theme::Javascript, "#{@theme.path}/javascripts/effects.js")
  end

  test "instantiates a valid Theme::Stylesheet for a valid asset extension" do
    expect_valid_file(uploaded_stylesheet, Theme::Stylesheet, "#{@theme.path}/stylesheets/styles.css")
  end

  test "destroys the attachment" do
    file = uploaded_template
    file.destroy
    file.path.should_not be_file
  end

  # VALIDATIONS

  test "is invalid when the extension is not registered for any type" do
    file = Theme::File.new :name => 'invalid.doc', :data => image_fixture
    file.should_not be_valid
    file.errors.on('data').should =~ /not a valid file type/
  end

  test "is invalid when directory contains dots" do
    file = Theme::File.new :path => '../invalid.png', :data => image_fixture
    file.should_not be_valid
    file.errors.on('data').should =~ /may not contain consecutive dots/
  end

  test "is invalid if name starts with non-word character" do
    file = Theme::File.new(:path => '__MACOSX/._event.html.erb')
    file.should_not be_valid
    file.errors.invalid?('name').should be_true
  end

  test "is invalid if directory starts with non-word character" do
    file = Theme::File.new(:path => '.hidden/evil.html.erb')
    file.should_not be_valid
    file.errors.invalid?('directory').should be_true
  end

  # CLASS METHODS

  test "type_for returns Theme::Template for valid template extensions" do
    Theme::Template.valid_extensions.each do |extension|
      Theme::File.type_for("", "foo#{extension}").should == "Theme::Template"
    end
  end

  test "type_for returns Theme::Image for valid image extensions" do
    Theme::Image.valid_extensions.each do |extension|
      Theme::File.type_for("", "foo.#{extension}").should == "Theme::Image"
    end
  end

  test "type_for returns Theme::Javascript for .js" do
    Theme::File.type_for("", "foo.js").should == "Theme::Javascript"
  end

  test "type_for returns Theme::Stylesheet for .js" do
    Theme::File.type_for("", "foo.js").should == "Theme::Javascript"
  end

  test "type_for returns Theme::Preview for a file images/preview.png" do
    Theme::File.type_for("images", "preview.png").should == "Theme::Preview"
  end

  # INSTANCE METHODS

  test "base_path returns the path relative to the theme directory" do
    uploaded_template.base_path.should == 'templates/foo/bar/template.html.erb'
  end

end