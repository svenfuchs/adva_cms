class UserCell < BaseCell
  tracks_cache_references :recent_articles, :track => ['@users']

  has_state :recent

  def recent
    # TODO make these before filters
    symbolize_options!
    set_site
    set_section

    @count = @opts[:count] || 5
    @users = User.all(:limit => @count, :order => "id DESC")

    nil
  end
end