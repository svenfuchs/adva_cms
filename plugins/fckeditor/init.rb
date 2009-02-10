# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{ |path| path =~ %r(^#{File.dirname(__FILE__)}) }

# copy assets if necessary
# javascripts_directory = File.join(RAILS_ROOT, 'public', 'javascripts', 'adva_fckeditor')
# unless File.directory?(javascripts_directory)
#   FileUtils.mkdir_p(javascripts_directory)
#   Dir[File.join(File.dirname(__FILE__), 'public', 'javascripts') + '/*'].each do |d|
#     FileUtils.cp_r(d, javascripts_directory)
#   end
# end

# include FCKeditor
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.javascript_expansions += ['fckeditor/fckeditor.js', 'setup_fckeditor.js']

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::JavaScriptSources.expansions[:adva_cms_admin] += ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']