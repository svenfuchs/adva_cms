ActionController::Routing::Routes.draw do |map|
  
  map.filter 'locale'
  map.filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
  map.filter 'root_section'
  map.filter 'sections'   

  map.from_plugin :adva_cms
  map.from_plugin :adva_blog
  map.from_plugin :adva_forum
  map.from_plugin :adva_wiki
  map.from_plugin :adva_assets
  map.from_plugin :adva_comments
  map.from_plugin :adva_user
  map.from_plugin :theme_support
  
end
