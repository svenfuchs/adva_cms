class Admin::BaseController < ApplicationController
  layout "admin"

  renders_with_error_proc :above_field
  include CacheableFlash
  include ContentHelper
  include ResourceHelper
  helper TableBuilder

  helper :base, :resource, :content, :filter

  helper_method :content_locale, :has_permission?

  prepend_before_filter :set_account
  before_filter :set_menu, :set_site, :set_section, :set_locale, :set_timezone

  after_filter :reset_locale

  authentication_required

  attr_accessor :site

  def expire_pages(pages)
    pages.each do |page|
      cache_dir = Account.page_cache_directory_for_site(page.site)
      Dir["#{cache_dir}.*"].each do |path|
        Pathname.new(path).rmtree if File.exists?(path)
      end
    end
    CachedPage.expire_pages(pages)
  end

  protected

    def set_account
      @account = Site.find_by_id(params[:site_id]).account
    end

    def set_site
      @site = @account.sites.find(params[:site_id]) if params[:site_id] if @account
    end

    def set_section
      @section =  @site.sections.find(params[:section_id]) if params[:section_id] if @site
    end

    def set_menu
      @menu = Menus::Admin::Sites.new
    end

    def current_resource
      @section || @site || Site.new
    end

    def require_authentication
      return redirect_to_login(t(:'adva.flash.login_to_access_admin_area_of_account')) unless current_user
      if current_user.accounts.empty? || @account && !current_user.privileged_account_member?(@account)
        flash[:notice] = t(:'adva.flash.no_permission_for_admin_area_of_account')
        redirect_to login_url
      end
    end

    def redirect_to_login(notice = nil)
      flash[:notice] = notice
      redirect_to login_url(:return_to => request.url)
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
      URI.unescape(params[:return_to] || begin
        url = Registry.get(:redirect, action)
        url = Registry.get(:redirect, url) if url.is_a?(Symbol)
        url = url.call(self) if url.is_a?(Proc)
        url || options[:default] || '/'
      end)
    end

    def current_page
      @page ||= params[:page].present? ? params[:page].to_i : 1
    end

    def set_locale
      params[:locale] =~ /^[\w]{2}$/ or raise 'invalid locale' if params[:locale]
      I18n.locale = params[:locale] || I18n.default_locale
      I18n.locale.untaint

      ActiveRecord::Base.locale = params[:cl].present? ? params[:cl].to_sym : nil
    end

    def set_timezone
      Time.zone = @site.timezone if @site
    end

    def update_role_context!(params)
      set_section if params[:section_id] and !@section
    end

    def content_locale
      ActiveRecord::Base.locale == I18n.default_locale ? nil : ActiveRecord::Base.locale
    end

    def reset_locale
      ActiveRecord::Base.locale = nil
    end
end
