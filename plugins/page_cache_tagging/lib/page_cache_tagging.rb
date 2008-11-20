module PageCacheTagging
  module ActMacro
    # Caches the actions using the page-caching approach and saves the references for the page
    #   caches_page_with_references :index, :show, 
    #                               :track => ['@article', '@articles', {'@site' => :tag_counts}]
    def caches_page_with_references(*actions)
      unless caches_page_with_references?
        include PageCacheTagging
      
        helper_method :cached_references
        attr_writer :cached_references
        alias_method_chain :render, :read_access_tracking 
        alias_method_chain :caching_allowed, :skipping
      end

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
      options = args.last.is_a?(Hash) ? args.last : {}
      @skip_caching = options.delete(:skip_caching) || !(track_options.has_key?(params[:action].to_sym)) || @skip_caching
      returning render_without_read_access_tracking(*args) do
        save_cache_references unless @skip_caching
      end
    end

    def track_read_access
      return unless perform_caching
      options = self.class.track_options[params[:action].to_sym] || {}
      @read_access_tracker ||= RecordReadAccessTracker.new self, options.clone
    end

    def save_cache_references
      return unless perform_caching
      track_read_access
      references = @read_access_tracker.references
      CachedPage.create_with_references @site, @section, request.path, references
    end

    def caching_allowed_with_skipping
      caching_allowed_without_skipping && !@skip_caching
    end
end

ActionController::Base.class_eval do 
  extend PageCacheTagging::ActMacro
  
  def expire_pages(pages)
    pages.each { |page| expire_page(page.url) }
    CachedPage.expire_pages(pages)
  end

  def expire_site_page_cache
    cache_dir = page_cache_directory
    if cache_dir.gsub('/', '') =~ /public$/ 
      # TODO can not simply kill the whole cache dir unless in multisite mode
      # this misses assets as stylesheets from themes though because they are
      # not referenced as cached, yet
      expire_pages CachedPage.find_all_by_site_id(@site.id)
    else
      @site.cached_pages.delete_all
      Pathname.new(cache_dir).rmtree rescue Errno::ENOENT
    end
    
    # expire asset_tag_helper file_exist_cache so that assets will be re-cached
    ActionController::Base.reset_file_exist_cache!
    ActionView::Base.reset_file_exist_cache!
  end
end
