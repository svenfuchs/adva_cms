I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

register_javascript_expansion :admin => %w( adva_newsletters/admin/newsletter )
