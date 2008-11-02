scenario :theme_with_files do
  @theme = stub_theme
  @themes = stub_themes

  @site.themes.stub!(:find).and_return @theme # TODO
  @site.themes.stub!(:find).with(:all).and_return @themes

  @image_exts     = %w(png jpg jpeg gif swf ico)
  @image_paths    = @image_exts.collect{|ext| "images/something.#{ext}"}
  @asset_paths    = %w(stylesheets/something.css javascripts/something.js) + @image_paths
  @other_paths    = %w(preview.png)
  @template_paths = %w(templates/layouts/layout.liquid templates/template.html.erb)

  @file = stub_theme_file
  @files = [@file, @file]

  Theme::File.stub!(:create).and_return @file
  ['templates', 'assets', 'others'].each do |type|
    @theme.stub!(type).and_return @files
  end

  [@image_paths, @asset_paths, @other_paths, @template_paths].each do |paths|
    paths.map!{|path| Pathname.new "#{@theme.path}#{path}" }
  end
  Pathname.stub!(:glob).and_return(@asset_paths + @template_paths)
end