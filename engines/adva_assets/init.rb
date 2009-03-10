I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

register_javascript_expansion :admin => %w( adva_assets/admin/asset.js adva_assets/admin/asset_widget.js )
register_stylesheet_expansion :admin => %w( adva_assets/admin/assets )
