# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::HasManyPosts

config.to_prepare do
  Section.register_type 'Forum'
end

register_stylesheet_expansion :default => %w( adva_forum/forum )
