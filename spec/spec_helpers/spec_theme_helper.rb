# most probably not the best way to do this ... 
class Pathname; def file?; true; end; end
class Theme::File; def save; end; def delete; end; end

module SpecThemeHelper
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
    Pathname.stub!(:glob).and_return(@asset_paths + @template_paths)

    @file = @theme.files.find('templates-layouts-layout-liquid')    
  end
end

