module MessagesHelper
  def recipients_list(site)
    site.users.collect {|u| [u.name, u.id]}.sort
  end
end