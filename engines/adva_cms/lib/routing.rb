module AdvaCms
  class Routes
    # A list of additional engines to load. 
    ADDITIONAL_ENGINES = %w(theme_support)

    # Loads routing for engines starting with 'adva_'
    def self.from_plugins(map)
      map.filter 'locale'
      map.filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
      map.filter 'section_root'
      map.filter 'section_paths'
      map.filter 'pagination'

      engines  = Engines.plugins.collect(&:name).select { |name| name =~ /^adva_/ }
      engines += ADDITIONAL_ENGINES
      engines.each do |engine|
        Rails.logger.info("Loading routes for engine #{engine}")
        map.from_plugin engine
      end
    end
  end
end
