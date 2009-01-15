module CacheReferences
  class Sweeper < ActionController::Caching::Sweeper
    def expire_cached_pages_by_site(site)
      expire_cached_pages site, CachedPage.find_all_by_site_id(site.id)
    end

    def expire_cached_pages_by_section(section)
      expire_cached_pages section, CachedPage.find_all_by_section_id(section.id)
    end

    def expire_cached_pages_by_reference(record, method = nil)
      expire_cached_pages record, CachedPage.find_by_reference(record, method)
    end

    def expire_cached_pages(record, pages)
      record.logger.warn cached_log_message_for(record, pages) if Site.cache_sweeper_logging
      controller.expire_pages(pages) if controller # TODO wtf ... why is controller sometimes nil here??
    end

    def cached_log_message_for(record, pages)
      msg = ["Expired pages referenced by #{record.class} ##{record.id}", "Expiring #{pages.size} page(s)"]
      pages.inject(msg) { |msg, page| msg << " - #{page.url}" }.join("\n")
    end
  end
end