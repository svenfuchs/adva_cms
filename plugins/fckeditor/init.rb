# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{ |path| path =~ %r(^#{File.dirname(__FILE__)}) }

register_javascript_expansion :admin  => ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']
