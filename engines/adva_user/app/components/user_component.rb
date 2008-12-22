class UserComponent < Components::Base
  def recent_users(*args)
    @users = User.all :limit => 5, :order => "id DESC"
    render
  end
end