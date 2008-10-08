module ActionView::Helpers::AssetTagHelper
  # TODO might want to create our own custom asset caching plugin. 
  # probably better than monkey-patching rails. --JMH
  def javascript_include_tag(*sources)
    options = sources.extract_options!.stringify_keys
    cache   = options.delete("cache")

    if ActionController::Base.perform_caching && cache
      joined_javascript_name = File.join( 'cache', perma_host, (cache == true ? 'all' : cache) + '.js' )
      joined_javascript_path = File.join(JAVASCRIPTS_DIR, joined_javascript_name)
      write_asset_file_contents(joined_javascript_path, compute_javascript_paths(sources))
      javascript_src_tag(joined_javascript_name, options)
    else
      expand_javascript_sources(sources).collect { |source| javascript_src_tag(source, options) }.join("\n")
    end
  end

  def stylesheet_link_tag(*sources)
    options = sources.extract_options!.stringify_keys
    cache   = options.delete("cache")

    if ActionController::Base.perform_caching && cache
      joined_stylesheet_name = File.join( 'cache', perma_host, (cache == true ? 'all' : cache) + '.css' )
      joined_stylesheet_path = File.join(STYLESHEETS_DIR, joined_stylesheet_name)

      write_asset_file_contents(joined_stylesheet_path, compute_stylesheet_paths(sources))
      stylesheet_tag(joined_stylesheet_name, options)
    else
      expand_stylesheet_sources(sources).collect { |source| stylesheet_tag(source, options) }.join("\n")
    end
  end
end

class ActionController::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end

class ActionView::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end
