require 'cgi'
require 'action_view/helpers/url_helper'
require 'action_view/helpers/tag_helper'

# "/Users/sven/Development/projects/adva-cms/adva-cms/themes/site-1/theme-1/stylesheets/styles.css"
# "/Users/sven/Development/projects/adva-cms/adva-cms/themes/theme-1/stylesheets/styles.css"

module ActionView
  module Helpers #:nodoc:
    module AssetTagHelper
      def theme_javascript_path(theme_name, source)
        create_theme_javascript_tag(theme_name, source).public_path
      end
      alias_method :path_to_theme_javascript, :theme_javascript_path

      def theme_javascript_include_tag(theme_name, *sources)
        options = sources.extract_options!.stringify_keys
        cache   = options.delete("cache")
        recursive = options.delete("recursive")
        sources = ThemeJavaScriptSources.create(self, @controller, sources, recursive) do |cache_key, sources|
          cache_key << theme_name
          sources.theme_name = theme_name
        end

        if ActionController::Base.perform_caching && cache
          joined_javascript_name = (cache == true ? "all" : cache) + ".js"
          segments = [ASSETS_DIR, 'themes', theme_name, 'javascripts', joined_javascript_name]
          segments.insert 1, 'cache', @controller.site.perma_host if Site.multi_sites_enabled
          joined_javascript_path = File.join(*segments)
          sources.write_joined_asset_files_contents(joined_javascript_path) unless File.exists?(joined_javascript_path)
          theme_javascript_src_tag(theme_name, joined_javascript_name, options)
        else
          sources.write_asset_files_contents
          sources.expand_sources.collect { |source| theme_javascript_src_tag(theme_name, source, options) }.join("\n")
        end
      end

      def theme_stylesheet_path(theme_name, source)
        create_theme_stylesheet_tag(theme_name, source).public_path
      end
      alias_method :path_to_theme_stylesheet, :theme_stylesheet_path # aliased to avoid conflicts with a stylesheet_path named route

      def theme_stylesheet_link_tag(theme_name, *sources)
        options = sources.extract_options!.stringify_keys
        cache   = options.delete("cache")
        recursive = options.delete("recursive")
        sources = ThemeStylesheetSources.create(self, @controller, sources, recursive) do |cache_key, sources|
          cache_key << theme_name
          sources.theme_name = theme_name
        end

        if ActionController::Base.perform_caching && cache
          joined_stylesheet_name = (cache == true ? "all" : cache) + ".css"
          segments = [ASSETS_DIR, 'themes', theme_name, 'stylesheets', joined_stylesheet_name]
          segments.insert 1, 'cache', @controller.site.perma_host if Site.multi_sites_enabled
          joined_stylesheet_path = File.join(*segments)

          sources.write_joined_asset_files_contents(joined_stylesheet_path) unless File.exists?(joined_stylesheet_path)
          theme_stylesheet_tag(theme_name, joined_stylesheet_name, options)
        else
          sources.write_asset_files_contents
          sources.expand_sources.collect { |source| theme_stylesheet_tag(theme_name, source, options) }.join("\n")
        end
      end

      def theme_image_path(theme_name, source)
        create_theme_image_tag(theme_name, source).public_path
      end
      alias_method :path_to_theme_image, :theme_image_path # aliased to avoid conflicts with an image_path named route


      def theme_image_tag(theme_name, source, options = {})
        options.symbolize_keys!

        options[:src] = path_to_theme_image(theme_name, source)
        options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end

        if mouseover = options.delete(:mouseover)
          options[:onmouseover] = "this.src='#{image_path(mouseover)}'"
          options[:onmouseout]  = "this.src='#{image_path(options[:src])}'"
        end

        # copy the file
        tag = create_theme_image_tag(theme_name, source)
        if File.exist?(tag.asset_file_path)
          segments = [ASSETS_DIR, tag.public_path.split('?').first]
          segments.insert 1, 'cache', @controller.site.perma_host if Site.multi_sites_enabled
          destination = File.join(segments)

          FileUtils.mkdir_p File.dirname(destination)
          FileUtils.cp tag.asset_file_path, destination
        end

        tag("img", options)
      end

      private
        def theme_javascript_src_tag(theme_name, source, options)
          content_tag("script", "", { "type" => Mime::JS, "src" => path_to_theme_javascript(theme_name, source) }.merge(options))
        end

        def theme_stylesheet_tag(theme_name, source, options)
          tag("link", { "rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen", "href" => html_escape(path_to_theme_stylesheet(theme_name, source)) }.merge(options), false, false)
        end

        def create_theme_image_tag(theme_name, source)
          returning ThemeImageTag.new(self, @controller, source) do |tag|
            tag.cache_key << theme_name
            tag.theme_name = theme_name
          end
        end

        def create_theme_javascript_tag(theme_name, source)
          returning ThemeJavaScriptTag.new(self, @controller, source) do |tag|
            tag.cache_key << theme_name
            tag.theme_name = theme_name
          end
        end

        def create_theme_stylesheet_tag(theme_name, source)
          returning ThemeStylesheetTag.new(self, @controller, source) do |tag|
            tag.cache_key << theme_name
            tag.theme_name = theme_name
          end
        end

        # FIX!
        class AssetTag
          private
            def compute_public_path(source)
              if source =~ ProtocolRegexp
                source += ".#{extension}" if missing_extension?(source)
                source = prepend_asset_host(source)
                source
              else
                CacheGuard.synchronize do
                  # cache key should include the source parameter or shouldn't it?
                  # otherwise we compute the same public path no matter what source
                  # is given
                  Cache[@cache_key + [source]] ||= begin
                    source += ".#{extension}" if missing_extension?(source) || file_exists_with_extension?(source)
                    source = "/#{directory}/#{source}" unless source[0] == ?/
                    source = rewrite_asset_path(source)
                    source = prepend_relative_url_root(source)
                    source = prepend_asset_host(source)
                    source
                  end
                end
              end
            end
        end

        module ThemeAssetTag
          attr_accessor :theme_name

          def public_path
            segments = [theme_name, directory, @source]
            compute_public_path(File.join('/themes', *segments))
          end
          
          def asset_file_path
            # HACK. @controller.site.id break with a superweird error on the second request because some
            # class_inheritable_attr is not there any more (:skip_time_zone_conversion_for_attributes)
            # The whole design seems to be flawed here. Will @controller.site really change per request 
            # here? Or is this stuff memoized somewhere in between?
            path = File.join('/themes', "site-#{@controller.site.attributes['id']}", theme_name, directory, @source)
            File.join(RAILS_ROOT, compute_public_path(path).split('?').first)
          end
        end

        class ThemeImageTag < ImageTag
          attr_accessor :cache_key
          include ThemeAssetTag
        end

        class ThemeJavaScriptTag < JavaScriptTag
          attr_accessor :cache_key
          include ThemeAssetTag
        end

        class ThemeStylesheetTag < StylesheetTag
          attr_accessor :cache_key
          include ThemeAssetTag
        end

        class AssetCollection
          # monkeypatch to accept a block, so we can customize the cache key
          # and set custom attributes (theme_name for our purpose) before the
          # collection get's frozen and cached
          def self.create(template, controller, sources, recursive)
            CacheGuard.synchronize do
              key = [self, sources, recursive]
              collection = new(template, controller, sources, recursive)
              yield key, collection if block_given?
              Cache[key] ||= collection.freeze
            end
          end
        end

        module ThemeAssetCollection
          attr_accessor :theme_name

          def write_asset_files_contents
            tag_sources.each do |source|
              segments = [ASSETS_DIR, source.public_path.split('?').first]
              segments.insert 1, 'cache', @controller.site.perma_host if Site.multi_sites_enabled
              write_asset_file_content(File.join(segments), source.contents, source.mtime)
            end
          end

          def write_joined_asset_files_contents(joined_asset_path)
            write_asset_file_content(joined_asset_path, joined_contents, latest_mtime)
          end

          def write_asset_file_content(destination, contents, mtime)
            FileUtils.mkdir_p(File.dirname(destination))
            File.open(destination, "w+") { |cache| cache.write(contents) }
            File.utime(mtime, mtime, destination)
          end

          def tag_sources
            expand_sources.collect do |source|
              returning tag_class.new(@template, @controller, source, false) do |tag|
                tag.cache_key << theme_name
                tag.theme_name = theme_name
              end
            end
          end
        end

        class ThemeJavaScriptSources < JavaScriptSources
          include ThemeAssetCollection

          private
            def tag_class
              ThemeJavaScriptTag
            end
        end

        class ThemeStylesheetSources < StylesheetSources
          include ThemeAssetCollection

          private
            def tag_class
              ThemeStylesheetTag
            end
        end
    end
  end
end
