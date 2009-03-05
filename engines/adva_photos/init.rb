# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '*.{rb,yml}')]

config.to_prepare do
  Section.register_type 'Album'
end