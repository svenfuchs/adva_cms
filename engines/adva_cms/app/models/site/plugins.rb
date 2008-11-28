class Site
  class Plugins < Engines::Plugin::List
    def initialize(site, plugins)
      @site = site
      plugins.each do |plugin|
        plugin = plugin.clone
        plugin.owner = site
        self << plugin
      end
    end
  end
end
