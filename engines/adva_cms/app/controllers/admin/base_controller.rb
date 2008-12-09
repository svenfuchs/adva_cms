class Admin::BaseController < ApplicationController
  layout "admin"
  
  renders_with_error_proc :below_field
  include CacheableFlash
  include Widgets

  before_filter :set_site, :set_locale, :set_timezone, :set_cache_root
  helper :base, :content, :comments, :users
  helper_method :admin_section_contents_path, :new_admin_content_path, :perma_host
  helper_method :has_permission?

  authentication_required

  attr_accessor :site

  widget :menu_global,   :partial => 'widgets/admin/menu_global'

  widget :menu_site,     :partial => 'widgets/admin/menu_site',
                         :except  => { :controller => 'admin/sites', :action => [:index, :new] }

  widget :section_tree,  :partial => 'widgets/admin/section_tree',
                         :except  => { :controller => 'admin/sites', :action => [:index, :new] },
                         :only    => { :controller => ['admin/sites', 'admin/sections', 'admin/articles', 'admin/wikipages'] }

  widget :sub_nav,       :partial => 'widgets/admin/sub_nav',
                         :except => { :controller => ['admin/sections'], :action => [:index, :new] },
                         :only  => { :controller => ['admin/sections', 'admin/articles', 'admin/wikipages', 'admin/categories', 'admin/comments'] }

  def admin_section_contents_path(section)
    content_type = section.class.content_type.pluralize.gsub('::', '_').underscore.downcase
    send(:"admin_#{content_type}_path", section.site, section)
  end

  def new_admin_content_path(section)
    type = section.class.content_type.pluralize.gsub('::', '_').underscore.downcase
    send :"new_admin_#{content_type}_path", section.site, section
  end

  protected

    def require_authentication
      update_role_context!(params) # TODO no idea what this is good for ...
      unless current_user and current_user.has_role?(:admin, :context => current_role_context) # TODO this is bad
        return redirect_to_login(t(:'adva.flash.authentication_required_role', :role => :admin))
      end
      super
    end

    def redirect_to_login(notice = nil)
      flash[:notice] = notice
      redirect_to login_path(:return_to => request.url)
    end

    def rescue_action(exception)
      if exception.is_a? ActionController::RoleRequired
        @error = exception
        render :template => 'shared/messages/insufficient_permissions'
      else
        super
      end
    end

    def return_from(action, options = {})
      params[:return_to] || begin
        url = Registry.get(:redirect, action)
        url = Registry.get(:redirect, url) if url.is_a?(Symbol)
        url = url.call(self) if url.is_a?(Proc)
        url || options[:default] || '/'
      end
    end

    def current_page
      @page ||= params[:page].blank? ? 1 : params[:page].to_i
    end

    def set_locale
      params[:locale] =~ /^[\w]{2}$/ or raise 'invalid locale' if params[:locale]
      I18n.locale = params[:locale] || I18n.default_locale
      I18n.locale.untaint
    end

    def set_timezone
      Time.zone = @site.timezone if @site
    end

    def set_site
      @site = Site.find(params[:site_id]) if params[:site_id]
      Thread.current[:site] = @site
    end

    def set_section
      @section =  @site.sections.find(params[:section_id]) if params[:section_id]
    end

    def update_role_context!(params)
      set_section if params[:section_id] and !@section
    end

    def current_role_context
      @section || @site || Site.new
    end

    def perma_host
      @site.try(:perma_host) || 'admin'
    end

    def page_cache_directory
      if Rails.env == 'test'
         Site.multi_sites_enabled ? 'tmp/cache/' + perma_host : 'tmp/cache'
       else
         Site.multi_sites_enabled ? 'public/cache/' + perma_host : 'public'
       end
    end

    def set_cache_root
      self.class.page_cache_directory = page_cache_directory.to_s
    end
end
