I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

register_javascript_expansion :admin => %w( adva_newsletter/admin/newsletter )
register_stylesheet_expansion :login => %w( adva_newsletter/subscription )
