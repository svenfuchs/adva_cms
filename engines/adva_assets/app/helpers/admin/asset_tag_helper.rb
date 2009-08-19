module Admin
  module AssetTagHelper
    # def asset_path(source)
    #   compute_public_path(source, Asset.base_url)
    # end
    # alias_method :path_to_image, :image_path # aliased to avoid conflicts with an image_path named route

    def asset_tag(asset, options = {})
      options.symbolize_keys!
      options[:src] = asset.base_url(options[:style]) # path_to_image(source)
      options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

      if size = options.delete(:size)
        options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
      end

      if mouseover = options.delete(:mouseover)
        options[:onmouseover] = "this.src='#{image_path(mouseover)}'"
        options[:onmouseout]  = "this.src='#{image_path(options[:src])}'"
      end

      tag("img", options)
    end

    # private
    #   def compute_public_path(source, dir, ext = nil, include_host = true)
    #     has_request = @controller.respond_to?(:request)
    #
    #     if ext && (File.extname(source).blank? || File.exist?(File.join(theme.path, dir, "#{source}.#{ext}")))
    #       source += ".#{ext}"
    #     end
    #
    #     unless source =~ %r{^[-a-z]+://}
    #       source = "/#{dir}/#{source}" unless source[0] == ?/
    #
    #       source = rewrite_asset_path(source)
    #
    #       if has_request && include_host
    #         unless source =~ %r{^#{ActionController::Base.relative_url_root}/}
    #           source = "#{ActionController::Base.relative_url_root}#{source}"
    #         end
    #       end
    #     end
    #
    #     if include_host && source !~ %r{^[-a-z]+://}
    #       host = compute_asset_host(source)
    #
    #       if has_request && host.present? && host !~ %r{^[-a-z]+://}
    #         host = "#{@controller.request.protocol}#{host}"
    #       end
    #
    #       "#{host}#{source}"
    #     else
    #       source
    #     end
    #   end
    #
    #   def rails_asset_id(source)
    #     if asset_id = ENV["RAILS_ASSET_ID"]
    #       asset_id
    #     else
    #       if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
    #         asset_id
    #       else
    #         path = File.join(theme.path, source)
    #         asset_id = File.exist?(path) ? File.mtime(path).to_i.to_s : ''
    #
    #         if @@cache_asset_timestamps
    #           @@asset_timestamps_cache_guard.synchronize do
    #             @@asset_timestamps_cache[source] = asset_id
    #           end
    #         end
    #
    #         asset_id
    #       end
    #     end
    #   end
    #
    #   def rewrite_asset_path(source)
    #     asset_id = rails_asset_id(source)
    #     if asset_id.blank?
    #       source
    #     else
    #       source + "?#{asset_id}"
    #     end
    #   end
    #
    #   # ------------------------------------------------------------------------
    #
    #   public
    #
    #     def self.cache_asset_timestamps
    #       @@cache_asset_timestamps
    #     end
    #
    #     def self.cache_asset_timestamps=(value)
    #       @@cache_asset_timestamps = value
    #     end
    #
    #     @@cache_asset_timestamps = true
    #
    #   private
    #
    #     def compute_asset_host(source)
    #       if host = ActionController::Base.asset_host
    #         if host.is_a?(Proc) || host.respond_to?(:call)
    #           case host.is_a?(Proc) ? host.arity : host.method(:call).arity
    #           when 2
    #             request = @controller.respond_to?(:request) && @controller.request
    #             host.call(source, request)
    #           else
    #             host.call(source)
    #           end
    #         else
    #           (host =~ /%d/) ? host % (source.hash % 4) : host
    #         end
    #       end
    #     end
    #
    #     @@asset_timestamps_cache = {}
    #     @@asset_timestamps_cache_guard = Mutex.new
    #
    #     def collect_asset_files(*path)
    #       dir = path.first
    #
    #       Dir[File.join(*path.compact)].collect do |file|
    #         file[-(file.size - dir.size - 1)..-1].sub(/\.\w+$/, '')
    #       end.sort
    #     end
  end
end