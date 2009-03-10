ActiveRecord::Base.send :include, ActiveRecord::HasManyPosts

config.to_prepare do
  Section.register_type 'Forum'
end

register_stylesheet_expansion :default => %w( adva_forum/forum )
