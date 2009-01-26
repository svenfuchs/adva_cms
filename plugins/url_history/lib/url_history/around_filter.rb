module UrlHistory
  class AroundFilter
    class << self
      def after(controller)
        url = controller.request.url.gsub(/\?.*$/, '')
        Entry.find(:first, :conditions => ["url = ? ", url]) or create_entry!(controller, url)
      end
      
      protected
      
        def create_entry!(controller, url)
          if controller.respond_to?(:current_resource) and resource = controller.current_resource
            Entry.create! :url => url, :resource => resource, :params => controller.params
          end
        end
    end
  end
end
