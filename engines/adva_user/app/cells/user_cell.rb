class UserCell < Cell::Base

  tracks_cache_references :recent_articles, :track => ['@users']
  
  def recent
    @count = @opts['count'] || 5
    @users = User.all(:limit => @count, :order => "id DESC")

    nil
  end
end