class Admin::InstallController < ApplicationController
  include CacheableFlash

  before_filter :protect_install, :except => :confirmation
  helper_method :perma_host

  layout 'simple'
  renders_with_error_proc :below_field

  def index
    params[:site] ||= {}
    params[:section] ||= {:title => 'Home', :type => 'Section'}

    @site = Site.new params[:site].merge(:host => request.host_with_port)
    @section = @site.sections.build params[:section]
    @site.sections << @section
    @user = User.new

    if request.post?
      if @site.valid? && @section.valid?
        @site.save

        @user = User.create_superuser params[:user]
        authenticate_user(:email => @user.email, :password => @user.password)

        flash.now[:notice] = 'Congratulations! You have successfully set up your site.'
        render :action => :confirmation
      else
        models = [@site, @section].map{|model| model.class.name unless model.valid?}.compact
        flash.now[:error] = "The #{models.join(' and ')} could not be created."
      end
    end
  end

  protected
    def perma_host
      @site.try(:perma_host) || 'admin'
    end

    def protect_install
      if Site.find(:first) || User.find(:first)
        flash[:error] = 'Installation is already complete. Please log in with your admin account.'
        redirect_to admin_sites_path
      end
    end
end
