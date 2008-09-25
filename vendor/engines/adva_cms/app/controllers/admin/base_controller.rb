class Admin::BaseController < ApplicationController
  layout "admin"

  renders_with_error_proc :below_field
  include CacheableFlash
  include Widgets

  before_filter :set_site, :set_locale, :set_timezone
  helper :base, :content, :comments, :users
  helper_method :admin_section_path_for

  authentication_required

  attr_accessor :site

  widget :menu_global,   :partial => 'widgets/admin/menu_global'

  widget :menu_site,     :partial => 'widgets/admin/menu_site',
                         :except  => { :controller => 'admin/sites', :action => [:index, :new] }

  widget :section_tree,  :partial => 'widgets/admin/section_tree',
                         :except  => { :controller => 'admin/sites', :action => [:index, :new] },
                         :only    => { :controller => ['admin/sites', 'admin/sections', 'admin/articles', 'admin/wikipages'] }

  widget :menu_section,  :partial => 'widgets/admin/menu_section',
                         :except => { :controller => ['admin/sections'], :action => [:index, :new] },
                         :only  => { :controller => ['admin/sections', 'admin/articles', 'admin/wikipages', 'admin/categories', 'admin/comments'] }


  # TODO delegate this to the section class? or the controller, even?
  # like Admin::WikipagesController.default_route_helper
  def admin_section_path_for(section)
    case section
      when Wiki     then admin_wikipages_path section.site, section
      when Blog     then admin_articles_path section.site, section
      when Forum    then admin_section_path section.site, section
      when Section  then admin_articles_path section.site, section
      # else                 admin_articles_path section.site, section
    end
  end

  protected

    def require_authentication
      unless current_user and current_user.has_role?(Role.build(:admin, @site))
        return redirect_to_login("You need to be an admin to view this page.")
      end
      super
    end

    def redirect_to_login(notice = nil)
      store_return_location
      flash[:notice] = notice
      redirect_to login_path
    end

    def rescue_action(exception)
      if exception.is_a? ActionController::RoleRequired
        @error = exception
        render :template => 'shared/messages/insufficient_permissions'
      else
        super
      end
    end

    def current_page
      @page ||= params[:page].blank? ? 1 : params[:page].to_i
    end

    def set_locale
      I18n.locale = params[:locale] || :en
    end

    def set_timezone
      Time.zone = @site.timezone if @site
    end

    def set_site
      @site = Site.find(params[:site_id])
      Thread.current[:site] = @site
    end

    def set_section
      @section =  @site.sections.find(params[:section_id]) if params[:section_id]
    end

    def current_role_context
      @section || @site || Site.new
    end

    def page_cache_directory
      raise "@site not set" unless @site
      @site.page_cache_directory
    end
end