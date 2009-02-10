# TODO why not put this into adva_cms/boot.rb?

Engines::RailsExtensions::Routing.module_eval do
  # TODO why not just load from all plugins that have a routes.rb file?
  
  # Loads routing for engines starting with 'adva_' 
  def from_plugins
    filter 'locale'
    filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
    filter 'sets'       # TODO fix: around_filter seems to call filters in reverse order
    filter 'section_root'
    filter 'section_paths'
    filter 'pagination'

    engines = Engines.plugins.collect(&:name).select { |name| name =~ /^adva_/ }
    engines.each do |engine|
      Rails.logger.info("Loading routes for engine #{engine}")
      from_plugin engine
    end
  end
end
