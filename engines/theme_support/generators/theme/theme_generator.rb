class ThemeGenerator < Rails::Generator::NamedBase     
   def manifest
      record do |m|
          # Theme folder(s)
          m.directory File.join( "themes", file_name )
          # theme content folders
          m.directory File.join( "themes", file_name, "images" )
          m.directory File.join( "themes", file_name, "javascript" )
          m.directory File.join( "themes", file_name, "templates" )
          m.directory File.join( "themes", file_name, "templates", "layouts" )
          m.directory File.join( "themes", file_name, "templates", "blog" )
          m.directory File.join( "themes", file_name, "templates", "shared" )
          m.directory File.join( "themes", file_name, "stylesheets" )
          # Default files...
          # about
          m.template 'about.markdown', File.join( 'themes', file_name, 'about.markdown' )
          m.template 'about.yml', File.join( 'themes', file_name, 'about.yml' )
          # image
          m.file 'preview.png', File.join( 'themes', file_name, 'images', 'preview.png' )
          # stylesheet
          m.template "theme.css", File.join( "themes", file_name, "stylesheets", "#{file_name}.css" )
          # views
          m.template 'blog_index.html.erb', File.join( 'themes', file_name, 'templates', 'blog', 'index.html.erb' )
          m.template '_footer.html.erb', File.join( 'themes', file_name, 'templates', 'shared', '_footer.html.erb' )
          # layouts
          m.template 'layout.erb.html', File.join( 'themes', file_name, 'templates', 'layouts', 'default.html.erb' )
          # readme
          m.template 'README', File.join( 'themes', file_name, 'README' )
          m.readme 'README'
      end
   end
end