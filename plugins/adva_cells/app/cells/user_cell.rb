class UserCell < BaseCell
  tracks_cache_references :recent_articles, :track => ['@users']

  has_state :recent

  def recent
    # FIXME make these before filters
    symbolize_options!
    set_site
    set_section
    
    # FIXME this works for single site scenario, but for multisite you probably want
    #       to get all the site users and not users from every site
    @count = @opts[:count] || 5
    @users = User.all(:limit => @count, :order => "id DESC")

    nil
  end
end