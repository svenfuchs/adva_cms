# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'theme_support'

