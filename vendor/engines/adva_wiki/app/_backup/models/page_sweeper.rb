class WikipageSweeper < ActionController::Caching::Sweeper
  observe Wikipage

  def after_save(record)
    expire_record(record.permalink)
    expire_parent_links(record.permalink)
  end

  def expire_record(permalink)
    RAILS_DEFAULT_LOGGER.info "Record to expire is: " + permalink.to_s
    expire_page("/#{permalink}")
  end

  def expire_parent_links(permalink)
    wiki_word = permalink.split("-").join(" ")
    wikipages = Wikipage.find_all_by_wiki_word(wiki_word)
    wikipages.each do |p| 
      expire_page("/#{p.permalink}")
      RAILS_DEFAULT_LOGGER.info "Parent record to expire is: " + p.permalink.to_s
    end
  end

end
