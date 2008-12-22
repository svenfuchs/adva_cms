class UserComponent < Components::Base
  def recent_users(*args)
    @users = Article.all :limit => 5
    render
  end
end