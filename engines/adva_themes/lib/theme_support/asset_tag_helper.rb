# With http://github.com/rails/rails/commit/104898fcb7958bcb69ba0239d6de8aa37f2da9ba
# Rails edge (2.3) reverted all the nice oop changes that were introduced to
# asset_tag_helper in 2.2 ... so no point to code against the 2.2'ish API
# any more. Ok, let's instead overwrite everything. OMG ... suck, why does
# this so remind me of PHP.

require 'action_view/helpers/asset_tag_helper'

module ActionView
  module Helpers
    module AssetTagHelper
      def theme_javascript_path(theme, source)
        theme = @controller.site.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)
        theme_compute_public_path(theme, source, theme.url + '/javascripts', 'js')
      end
      alias_method :theme_path_to_javascript, :theme_javascript_path

      def theme_javascript_include_tag(theme_id, *sources)
        theme = @controller.site.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options = sources.extract_options!.stringify_keys
        cache   = options.delete("cache")
        recursive = options.delete("recursive")

        if ActionController::Base.perform_caching && cache
          joined_javascript_name = (cache == true ? "all" : cache) + ".js"
          joined_javascript_path = File.join(theme.path + '/javascripts', joined_javascript_name)

          paths = theme_compute_javascript_paths(theme, sources, recursive)
          theme_write_asset_file_contents(theme, joined_javascript_path, paths) unless File.exists?(joined_javascript_path)
          theme_javascript_src_tag(theme, joined_javascript_name, options)
        else
          theme_expand_javascript_sources(theme, sources, recursive).collect do |source|
            theme_javascript_src_tag(theme, source, options)
          end.join("\n")
        end
      end

      def theme_stylesheet_path(theme, source)
        theme = @controller.site.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)
        theme_compute_public_path(theme, source, theme.url + '/stylesheets', 'css')
      end
      alias_method :theme_path_to_stylesheet, :theme_stylesheet_path

      def theme_stylesheet_link_tag(theme_id, *sources)
        theme = @controller.site.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options = sources.extract_options!.stringify_keys
        cache   = options.delete("cache")
        recursive = options.delete("recursive")

        if ActionController::Base.perform_caching && cache
          joined_stylesheet_name = (cache == true ? "all" : cache) + ".css"
          joined_stylesheet_path = File.join(theme.path + '/stylesheets', joined_stylesheet_name)
          
          paths = theme_compute_stylesheet_paths(theme, sources, recursive)
          theme_write_asset_file_contents(theme, joined_stylesheet_path, paths) unless File.exists?(joined_stylesheet_path)
          theme_stylesheet_tag(theme, joined_stylesheet_name, options)
        else
          theme_expand_stylesheet_sources(theme, sources, recursive).collect do |source|
            theme_stylesheet_tag(theme, source, options)
          end.join("\n")
        end
      end

      def theme_image_path(theme, source)
        theme = @controller.site.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)
        theme_compute_public_path(theme, source, theme.url + '/images')
      end
      alias_method :theme_path_to_image, :theme_image_path # aliased to avoid conflicts with an image_path named route

      def theme_image_tag(theme_id, source, options = {})
        theme = @controller.site.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options.symbolize_keys!
        options[:src] = theme_path_to_image(theme, source)
        options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end

        if mouseover = options.delete(:mouseover)
          options[:onmouseover] = "this.src='#{theme_image_path(theme, mouseover)}'"
          options[:onmouseout]  = "this.src='#{theme_image_path(theme, options[:src])}'"
        end

        tag("img", options)
      end

      private
        def theme_compute_public_path(theme, source, dir, ext = nil, include_host = true)
          has_request = @controller.respond_to?(:request)

          if ext && (File.extname(source).blank? || File.exist?(File.join(theme.path, dir, "#{source}.#{ext}")))
            source += ".#{ext}"
          end

          unless source =~ %r{^[-a-z]+://}
            source = "/#{dir}/#{source}" unless source[0] == ?/

            source = theme_rewrite_asset_path(theme, source)

            if has_request && include_host
              unless source =~ %r{^#{ActionController::Base.relative_url_root}/}
                source = "#{ActionController::Base.relative_url_root}#{source}"
              end
            end
          end

          if include_host && source !~ %r{^[-a-z]+://}
            host = compute_asset_host(source)

            if has_request && host.present? && host !~ %r{^[-a-z]+://}
              host = "#{@controller.request.protocol}#{host}"
            end

            "#{host}#{source}"
          else
            source
          end
        end

        def theme_rails_asset_id(theme, source)
          if asset_id = ENV["RAILS_ASSET_ID"]
            asset_id
          else
            if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
              asset_id
            else
              path = File.join(theme.path, source)
              asset_id = File.exist?(path) ? File.mtime(path).to_i.to_s : ''

              if @@cache_asset_timestamps
                @@asset_timestamps_cache_guard.synchronize do
                  @@asset_timestamps_cache[source] = asset_id
                end
              end

              asset_id
            end
          end
        end

        def theme_rewrite_asset_path(theme, source)
          asset_id = theme_rails_asset_id(theme, source)
          if asset_id.blank?
            source
          else
            source + "?#{asset_id}"
          end
        end

        def theme_javascript_src_tag(theme, source, options)
          options = { "type" => Mime::JS, "src" => theme_path_to_javascript(theme, source) }.merge(options)
          content_tag("script", "", options)
        end

        def theme_stylesheet_tag(theme, source, options)
          options = { "rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen",
                      "href" => html_escape(theme_path_to_stylesheet(theme, source)) }.merge(options)
          tag("link", options, false, false)
        end

        def theme_compute_javascript_paths(theme, *args)
          theme_expand_javascript_sources(theme, *args).collect do |source|
            theme_compute_public_path(theme, source, theme.url + '/javascripts', 'js', false)
          end
        end

        def theme_compute_stylesheet_paths(theme, *args)
          theme_expand_stylesheet_sources(theme, *args).collect do |source|
            theme_compute_public_path(theme, source, theme.url + '/stylesheets', 'css', false)
          end
        end

        def theme_expand_javascript_sources(theme, sources, recursive = false)
          if sources.include?(:all)
            all_javascript_files = collect_asset_files(theme.path + '/javascripts', ('**' if recursive), '*.js').uniq
          else
            sources.collect { |source| determine_source(source, {}) }.flatten
          end
        end

        def theme_expand_stylesheet_sources(theme, sources, recursive)
          if sources.first == :all
            collect_asset_files(theme.path + '/stylesheets', ('**' if recursive), '*.css')
          else
            sources.collect do |source|
              determine_source(source, {})
            end.flatten
          end
        end

        def theme_write_asset_file_contents(theme, joined_asset_path, asset_paths)
          FileUtils.mkdir_p(File.dirname(joined_asset_path))
          File.open(joined_asset_path, "w+") do |cache|
            cache.write(theme_join_asset_file_contents(theme, asset_paths))
          end
          mt = asset_paths.map { |p| File.mtime(theme_asset_file_path(theme, p)) }.max
          File.utime(mt, mt, joined_asset_path)
        end

        def theme_join_asset_file_contents(theme, paths)
          paths.collect { |path| File.read(theme_asset_file_path(theme, path)) }.join("\n\n")
        end

        def theme_asset_file_path(theme, path)
          File.join(Theme.root_dir, path.split('?').first)
        end
    end
  end
end