ActionController::Routing::Routes.draw do |map|
  
  map.filter 'locale'
  map.filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
  map.filter 'root_section'
  map.filter 'sections'
  map.filter 'pagination'

  AdvaCms::Routes.from_plugins(map)

end
