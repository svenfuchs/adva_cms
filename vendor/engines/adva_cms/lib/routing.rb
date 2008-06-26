module AdvaCMS
  class Routes
    # A list of additional engines to load. 
    ADDITIONAL_ENGINES = %w(theme_support)

    # Loads routing for engines starting with 'adva_'
    def self.from_plugins(map)
      engines  = Engines.plugins.collect(&:name).select { |name| name =~ /^adva_/ }
      engines += ADDITIONAL_ENGINES
      engines.each do |engine|
        Rails.logger.info("Loading routes for engine #{engine}")
        map.from_plugin engine
      end
    end
  end
end
