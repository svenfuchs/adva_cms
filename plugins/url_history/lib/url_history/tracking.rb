module UrlHistory
  module Tracking
    class << self
      def included(base)
        base.send :extend, ActMacro
      end
    end

    module ActMacro
      def tracks_url_history(options = {})
        return if tracks_url_history?
        
        include InstanceMethods

        class_inheritable_accessor  :url_history_options
        write_inheritable_attribute :url_history_options, options

        after_filter UrlHistory::AroundFilter
        
        rescue_from ActiveRecord::RecordNotFound, :with => :url_history_record_not_found
      end
    
      def tracks_url_history?
        included_modules.include? UrlHistory::Tracking::InstanceMethods
      end
    end
  
    module InstanceMethods
      def url_history_record_not_found
        if entry = UrlHistory::Entry.recent_by_url(request.url)
          params = entry.updated_params.except('method')
          url = url_for(params)
          redirect_to url unless request.url == url
        end
      end
    end
  end
end
