module CachedPagesHelper
  def page_cached_at(page)
    if Date.today == page.updated_at.to_date
      if page.updated_at > Time.zone.now - 4.hours
        "#{time_ago_in_words(page.updated_at).gsub(/about /,'~ ')} ago"
      else
        "Today, #{page.updated_at.strftime('%l:%M %p')}"
      end
    else
      page.updated_at.strftime("%b %d, %Y")
    end
  end
end
