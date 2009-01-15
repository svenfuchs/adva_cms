class WikipageSweeper < CacheReferences::Sweeper
  observe Wikipage

  def after_save(wikipage)
    if wikipage.home?
      expire_cached_pages_by_section wikipage.section
    else
      expire_cached_pages_by_reference wikipage
    end
  end

  alias after_destroy after_save
end