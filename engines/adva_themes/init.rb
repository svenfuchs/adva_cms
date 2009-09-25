I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

require 'theme_support'

register_javascript_expansion :admin => %w( adva_themes/admin/theme )
register_javascript_expansion :admin_alternate => %w( adva_themes/admin/theme )
