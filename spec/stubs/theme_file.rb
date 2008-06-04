define Theme::File do
  instance :theme_file, 
           :id => 'templates-layouts-layout-liquid',
           :path => 'templates/layouts/layout.liquid', 
           :localpath => 'templates/layouts/layout.liquid',
           :data => 'data',
           :valid? => true,
           :text? => true,
           :update_attributes => true, 
           :destroy => true
end

scenario :theme_file do
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
