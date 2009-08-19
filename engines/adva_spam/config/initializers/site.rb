class SiteFormBuilder < ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    site = @template.controller.site || Site.new
    render :partial => 'admin/sites/spam_settings', :locals => { :f => f, :site => site }
  end
end

ActionController::Dispatcher.to_prepare do
  Site.class_eval do
    def spam_options=(options)
      if options.is_a?(Hash)
        options = options.deep_symbolize_keys
        options.deep_compact! { |key, value| value == '' }
      end
      write_attribute :spam_options, options
    end

    def spam_options(*keys)
      result = read_attribute(:spam_options) || { :default => { :ham => 'authenticated' } }
      keys.each do |key|
        return nil unless result.has_key?(key)
        result = result[key]
      end
      result
    end

    def spam_filter_active?(name)
      (spam_options[:filters] || []).include?(name)
    end

    def spam_engine
      @spam_engine ||= SpamEngine::FilterChain.assemble(self.spam_options)
    end
  end
end