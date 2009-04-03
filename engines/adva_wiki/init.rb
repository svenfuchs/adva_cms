config.to_prepare do
  Section.register_type 'Wiki'
end

I18n.load_path += Dir[File.dirname(__FILE__) + '/config/locales/**/*.yml']

register_javascript_expansion :admin  => %w( adva_wiki/admin/wiki.js )
