require 'meta_tags/article_form_builder'

config.to_prepare do
  require 'base_controller'
  require 'admin/base_controller'
  
  BaseController.helper :meta_tags
  Admin::BaseController.helper :meta_tags

  Article.non_versioned_columns += %w(meta_author meta_geourl meta_copyright meta_keywords meta_description)
  Article.non_versioned_columns.uniq!
end