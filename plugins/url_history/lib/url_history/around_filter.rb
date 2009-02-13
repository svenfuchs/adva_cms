module UrlHistory
  class AroundFilter
    class << self
      def after(controller)
        return unless controller.request.get?
        url = controller.request.url.gsub(/\?.*$/, '')
        Entry.find(:first, :conditions => ["url = ? ", url]) or create_entry!(controller, url)
      end
      
      protected
      
        def create_entry!(controller, url)
          if !url.match(%r(/admin/)) and resource = controller.try(:current_resource)
            Entry.create! :url => url, :resource => resource, :params => stringify(controller.params)
          end
        end
        
        def stringify(hash)
          hash.each { |key, value| hash[key] = value.to_s if value.is_a?(Symbol) }
          hash
        end
    end
  end
end
