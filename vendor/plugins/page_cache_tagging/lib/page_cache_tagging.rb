module PageCacheTagging
  module ActMacro
    # Caches the actions using the page-caching approach and saves the references for the page
    #   caches_page_with_references :index, :show, 
    #                               :track => ['@article', '@articles', {'@site' => :tag_counts}]
    def caches_page_with_references(*actions)
      include PageCacheTagging
      
      helper_method :cached_references
      attr_writer :cached_references
      alias_method_chain :render, :read_access_tracking unless caches_page_with_references?

      options = actions.extract_options!
      caches_page *actions

      class_inheritable_accessor :track_options
      self.track_options ||= {}
    
      actions.map(&:to_sym).each do |action|
        self.track_options[action] = options[:track]
      end
    end
  
    def caches_page_with_references?
      method_defined? :render_without_read_access_tracking
    end
  end
  
  protected

    def render_with_read_access_tracking(*args)
      track_read_access 
      returning render_without_read_access_tracking(*args) do
        save_cache_references
      end
    end

    def track_read_access
      return unless perform_caching
      options = self.class.track_options[params[:action].to_sym] || {}
      @read_access_tracker ||= RecordReadAccessTracker.new self, options.clone
    end

    def save_cache_references
      return unless perform_caching
      references = @read_access_tracker.references
      CachedPage.create_with_references @site, @section, request.path, references
    end
end

ActionController::Base.send :extend, PageCacheTagging::ActMacro