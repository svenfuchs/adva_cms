module UsersHelper
  def who(name)
    name = name.name if name.is_a? User
    return current_user && current_user.name == name ? "You" : name
  end

  def gravatar_img(user, options = {})
    image_tag gravatar_url(user.email), {:class => 'avatar'}.merge(options)
  end

  def gravatar_url(email = nil, size = 80)
    default = '/images/adva_cms/avatar.gif'
    return default if email.blank?
    require 'digest/md5'
    digest = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{digest}&default=http://#{request.host_with_port}#{ActionController::AbstractRequest.relative_url_root}/images/adva_cms/avatar.gif"
  end
  
  def link_to_cancel(site = nil)
    site.nil? ? link_to("cancel", admin_users_path) : link_to("cancel", admin_site_users_path(site))
  end
end