config.to_prepare do
  Section.register_type 'Blog'
end

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']