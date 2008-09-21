ActionController::Routing::Routes.draw do |map|
  
  map.filter 'locale'
  map.filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
  map.filter 'section_root'
  map.filter 'section_paths'
  map.filter 'pagination'

  AdvaCms::Routes.from_plugins(map)

end
