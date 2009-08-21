module UrlHistory
  class AfterFilter
    class << self
      def filter(controller)
        return unless controller.request.get?
        url = controller.request.url.gsub(/\?.*$/, '')
        Entry.find(:first, :conditions => ["url = ? ", url]) or create_entry!(controller, url)
      end

      protected

        def create_entry!(controller, url)
          if !url.match(%r(/admin(/|$))) and resource = current_resource(controller) and !resource.new_record?
            entry = Entry.create!(:url => url, :resource => resource, :params => stringify(controller.params))
          end
        end

        def current_resource(controller)
          controller.send(:current_resource) rescue nil
        end

        def stringify(hash)
          hash.each { |key, value| hash[key] = value.to_s if value.is_a?(Symbol) }
          hash
        end
    end
  end
end
