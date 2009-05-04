class ContentCell < BaseCell
  tracks_cache_references :recent, :track => ['@section', '@articles', '@wikipages']
  
  has_state :recent
  
  def recent
    # TODO make these before filters
    symbolize_options!
    set_site
    set_section
    
    order = @opts[:order] ? @opts[:order] : "created_at DESC"
    limit = @opts[:limit] ? @opts[:limit] : 10
    @content = Content.published(:order => order, :limit => limit)
    nil
  end
end