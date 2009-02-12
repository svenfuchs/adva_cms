require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

module ThemeTestHelper
  def template_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/template.html.erb")
  end

  def image_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/rails.png")
  end

  def preview_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/preview.png")
  end

  def javascript_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/effects.js")
  end

  def stylesheet_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/styles.css")
  end

  def uploaded_template(theme = @theme)
    Theme::File.create! :theme => theme, :path => 'foo/bar/template.html.erb', :data => template_fixture
  end

  def uploaded_image(theme = @theme)
    Theme::File.create! :theme => theme, :path => 'rails.png', :data => image_fixture
  end

  def uploaded_preview(theme = @theme)
    Theme::File.create! :theme => theme, :path => 'preview.png', :data => preview_fixture
  end

  def uploaded_javascript(theme = @theme)
    Theme::File.create! :theme => theme, :path => 'effects.js', :data => javascript_fixture
  end

  def uploaded_stylesheet(theme = @theme)
    Theme::File.create! :theme => theme, :path => 'styles.css', :data => stylesheet_fixture
  end

  def theme_fixture
    File.new("#{File.dirname(__FILE__)}/fixtures/theme-for-import.zip")
  end
end