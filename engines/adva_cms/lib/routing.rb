Engines::RailsExtensions::Routing.module_eval do
  # A list of additional engines to load. 
  ADDITIONAL_ENGINES = %w(theme_support)

  # TODO why not just load from all plugins that have a routes.rb file?
  
  # Loads routing for engines starting with 'adva_' 
  def from_plugins
    filter 'locale'
    filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
    filter 'section_root'
    filter 'section_paths'
    filter 'pagination'

    engines  = Engines.plugins.collect(&:name).select { |name| name =~ /^adva_/ }
    engines += ADDITIONAL_ENGINES
    engines.each do |engine|
      Rails.logger.info("Loading routes for engine #{engine}")
      from_plugin engine
    end
  end
end