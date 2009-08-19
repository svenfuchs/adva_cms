class Admin::InstallController < ApplicationController
  include CacheableFlash
  helper :base

  before_filter :normalize_install_params, :only => :index
  before_filter :protect_install, :except => :confirmation
  filter_parameter_logging :password

  layout 'simple'
  renders_with_error_proc :below_field

  def index
    # TODO: can't we somehow encapsulate all this in a single model instead of juggling with 3 different models?
    params[:content] = params[:section]
    params[:content] ||= { :title => t(:'adva.sites.install.section_default') }
    params[:content][:type] ||= 'Page'

    @site = Site.new(params[:site])
    @section = @site.sections.build(params[:content])
    @user = User.new(params[:user])
    @user.name = @user.first_name_from_email

    if request.post?
      if @site.valid? && @section.valid? && @user.valid?
        @site.save

        @user = User.create_superuser(params[:user])
        authenticate_user(:email => @user.email, :password => @user.password)

        # default email for site
        @site.email ||= @user.email
        @site.save

        flash.now[:notice] = t(:'adva.sites.flash.install.success')
        render :action => :confirmation
      else
        models = [@site, @section, @user].map { |model| model.class.name unless model.valid? }.compact
        flash.now[:error] = t(:'adva.sites.flash.install.failure', :models => models.join(', '))
      end
    end
  end

  protected
    def normalize_install_params
      params[:site] ||= {}
      params[:site].merge!(:host => request.host_with_port)
    end

    def perma_host
      @site.try(:perma_host) || 'admin'
    end

    def protect_install
      if Site.find(:first) || User.find(:first)
        flash[:error] = t(:'adva.sites.flash.install.error_already_complete')
        redirect_to admin_sites_url
      end
    end
end
