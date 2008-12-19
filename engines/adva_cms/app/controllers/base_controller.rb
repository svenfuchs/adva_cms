require 'widgets'

class BaseController < ApplicationController
  class SectionRoutingError < ActionController::RoutingError; end
  helper :base, :content, :comments, :users, :roles
  helper_method :perma_host

  include ContentHelper # WTF!

  include CacheableFlash
  include Widgets

  before_filter :set_site, :set_section, :set_locale, :set_timezone, :set_cache_root
  around_filter OutputFilter::Cells.new
  attr_accessor :site

  layout 'default'
  widget :sections, :partial => 'widgets/sections'


  acts_as_themed_controller :current_themes => lambda {|c| c.site.current_themes if c.site }
  #                          :force_template_types => ['html.serb', 'liquid']
  #                          :force_template_types => lambda {|c| ['html.serb', 'liquid'] unless c.class.name =~ /^Admin::/ }

  # TODO move these to acts_as_commentable (?)
  caches_page_with_references :comments, :track => ['@commentable']

  filter_parameter_logging :password

  def comments
    @comments = @commentable.approved_comments
    respond_to do |format|
      format.atom { render :template => 'comments/comments', :layout => false }
    end
  end

  protected
    def set_section; super(Album); end
    
    def set_site
      @site = Site.find_by_host(request.host_with_port)
      Thread.current[:site] = @site
    end

    def set_section(type = nil)
      if @site
        @section = params[:section_id].blank? ? @site.sections.root : @site.sections.find(params[:section_id])
      end
      if type && !@section.is_a?(type)
        raise SectionRoutingError.new("Section must be a #{type.name}: #{@section.inspect}")
      end
    end

    def set_locale
      params[:locale] =~ /^[\w]{2}$/ or raise 'invalid locale' if params[:locale]
      I18n.locale = params[:locale] || I18n.default_locale
      # TODO raise something more meaningful
      I18n.locale.untaint
    end

    def set_timezone
      Time.zone = @site.timezone if @site
    end

    def current_page
      @page ||= params[:page].blank? ? 1 : params[:page].to_i
    end

    def set_commentable
      @commentable = @article || @section || @site
    end

    def rescue_action(exception)
      if exception.is_a? ActionController::RoleRequired
        redirect_to_login exception.message
      else
        super
      end
    end

    def redirect_to_login(notice = nil)
      flash[:notice] = notice
      redirect_to login_path(:return_to => request.url)
    end

    def return_from(action, options = {})
      params[:return_to] || begin
        url = Registry.get(:redirect, action)
        url = Registry.get(:redirect, url) if url.is_a?(Symbol)
        url = url.call(self) if url.is_a?(Proc)
        url || options[:default] || '/'
      end
    end
    
    def current_role_context
      @section || @site
    end

    def perma_host
      @site ? @site.perma_host : ''
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



