class UserCell < Cell::Base
  def recent
    @count = @opts['count'] || 5
    @users = User.all(:limit => @count, :order => "id DESC")

    nil
  end
end