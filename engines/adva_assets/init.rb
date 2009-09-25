I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

register_javascript_expansion :admin => %w( adva_assets/admin/asset adva_assets/admin/asset_widget )
register_stylesheet_expansion :admin => %w( adva_assets/admin/assets )
register_stylesheet_expansion :admin_projection => %w( adva_assets/admin/projection/assets )
register_stylesheet_expansion :admin_alternate => %w( adva_assets/admin/alternate/assets )
