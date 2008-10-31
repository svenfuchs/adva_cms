class Admin::InstallController < ApplicationController
  include CacheableFlash

  before_filter :protect_install, :except => :confirmation

  layout 'simple'
  renders_with_error_proc :below_field

  def index
    params[:site] ||= {}
    params[:section] ||= {:title => 'Home', :type => 'Section'}

    @site = Site.new params[:site].merge(:host => request.host_with_port)
    @section = @site.sections.build params[:section]
    @site.sections << @section

    if request.post?
      if @site.valid? && @section.valid?
        @site.save
        credentials = {:email => 'admin@example.org', :password => 'admin'}
        @user = User.create_superuser credentials.update(:first_name => 'admin', 
          :email => "admin@admin.org")
        authenticate_user credentials

        flash.now[:notice] = 'Congratulations! You have successfully set up your site.'
        render :action => :confirmation
      else
        models = [@site, @section].map{|model| model.class.name unless model.valid?}.compact
        flash.now[:error] = "The #{models.join(' and ')} could not be created."
      end
    end
  end

  protected

    def protect_install
      if Site.find(:first) || User.find(:first)
        flash[:error] = 'Installation is already complete. Please log in with your admin account.'
        redirect_to admin_sites_path
      end
    end
end
