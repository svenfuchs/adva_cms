module UrlHistory
  module Tracking
    class << self
      def included(base)
        base.send :extend, ActMacro
      end
    end

    module ActMacro
      def tracks_url_history
        return if tracks_url_history?

        include InstanceMethods

        after_filter UrlHistory::AfterFilter

        rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, 
                    :with => :url_history_page_not_found
      end

      def tracks_url_history?
        included_modules.include? UrlHistory::Tracking::InstanceMethods
      end
    end

    module InstanceMethods
      def url_history_page_not_found(exception)
        if entry = UrlHistory::Entry.recent_by_url(request.url)
          params = entry.updated_params.except('method')
          url = url_for(params)
          redirect_to(url) and return unless request.url == url # TODO add status 301
        end

        if handler = handler_for_rescue_except_url_history(exception)
          handler.arity != 0 ? handler.call(exception) : handler.call
        else
          rescue_action_without_handler(exception)
        end
      end
      
      # ugh. rescue_from does not allow chaining handlers. so instead of just
      # re-raising the exception we need to reimplement the logic, look up the
      # next handler and call it.
      def handler_for_rescue_except_url_history(exception)
        _, rescuer = Array(self.class.rescue_handlers).reverse.detect do |klass_name, handler|
          unless handler == :url_history_page_not_found
            klass = self.class.const_get(klass_name) rescue nil
            klass ||= klass_name.constantize rescue nil
            exception.is_a?(klass) if klass
          end
        end

        case rescuer
        when Symbol
          method(rescuer)
        when Proc
          rescuer.bind(self.class)
        end
      end
    end
  end
end

ActionController::Base.send :include, UrlHistory::Tracking
