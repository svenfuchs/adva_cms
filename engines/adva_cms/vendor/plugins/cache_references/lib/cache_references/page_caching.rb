require 'cache_references/method_call_tracking'

module CacheReferences
  module PageCaching
    module ActMacro

      # Caches the actions using the page-caching approach and sets up reference
      # tracking for given actions and objects
      #
      #   caches_page_with_references :index, :show, :track => ['@article', '@articles', {'@site' => :tag_counts}]
      #
      def caches_page_with_references(*actions)
        tracks_cache_references(*actions)

        unless caches_page_with_references?
          alias_method_chain :caching_allowed, :skipping
        end

        options = actions.extract_options!
        caches_page *actions
      end

      # Sets up reference tracking for given actions and objects
      #
      #   tracks_cache_references :index, :show, :track => ['@article', '@articles', {'@site' => :tag_counts}]
      #
      def tracks_cache_references(*actions)
        unless tracks_cache_references?
          include CacheReferences::PageCaching

          helper_method :cached_references
          attr_writer :cached_references
          alias_method_chain :render, :cache_reference_tracking

          class_inheritable_accessor :track_options
          self.track_options ||= {}
        end

        options = actions.extract_options!
        actions.map(&:to_sym).each do |action|
          self.track_options[action] ||= []
          self.track_options[action] += Array(options[:track])
          self.track_options[action].uniq!
        end
      end

      def caches_page_with_references?
        method_defined? :caching_allowed_without_skipping
      end

      def tracks_cache_references?
        method_defined? :render_without_cache_reference_tracking
      end
    end

    def skip_caching!
      @skip_caching = true
    end

    def skip_caching?
      @skip_caching == true
    end

    protected

      def render_with_cache_reference_tracking(*args, &block)
        options = args.last.is_a?(Hash) ? args.last : {}
        # skips caching if :skip_caching => true was passed or action is not configured to be cached
        skip_caching! if options.delete(:skip_caching) || !(track_options.has_key?(current_action))

        setup_method_call_tracking if track_method_calls?
        returning render_without_cache_reference_tracking(*args, &block) do
          save_cache_references if track_method_calls?
        end
      end

      def current_action
        params[:action].to_sym
      end

      def track_method_calls?
        perform_caching and not skip_caching?
      end

      def setup_method_call_tracking
        @method_call_tracker ||= MethodCallTracking::MethodCallTracker.new
        @method_call_tracker.track(self, *method_call_trackables)
      end

      def method_call_trackables
        trackables = self.class.track_options[current_action] || {}
        trackables.clone
      end

      def save_cache_references
        CachedPage.create_with_references(site, section, request.path, @method_call_tracker.references)
      end

      def caching_allowed_with_skipping
        caching_allowed_without_skipping && !skip_caching?
      end
  end
end

ActionController::Base.send :extend, CacheReferences::PageCaching::ActMacro
