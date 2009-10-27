class Admin::WikipagesController < Admin::BaseController
  helper :wiki

  before_filter :set_section
  before_filter :set_wikipage, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]
  before_filter :optimistic_lock, :only => :update
  
  cache_sweeper :wikipage_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  guards_permissions :wikipage

  def index
    @wikipages = @section.wikipages.paginate :page => current_page, :per_page => params[:per_page]
  end

  def new
    @wikipage = @section.wikipages.build(:title => @section.wikipages.present? ? nil : 'Home')
  end

  def create
    @wikipage = @section.wikipages.create(params[:wikipage])
    if @wikipage.valid?
      trigger_events(@wikipage)
      flash[:notice] = t(:'adva.wikipage.flash.create.succsess')
      redirect_to edit_admin_wikipage_url(@site, @section, @wikipage)
    else
      flash[:error] = t(:'adva.wikipage.flash.create.failure')
      set_categories
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    params[:wikipage][:version] ? rollback : update_attributes
  end

  def update_attributes
    if @wikipage.update_attributes(params[:wikipage])
      trigger_events(@wikipage)
      flash[:notice] = t(:'adva.wikipage.flash.update_attributes.success')
      redirect_to edit_admin_wikipage_url
    else
      flash[:error] = t(:'adva.wikipage.flash.update_attributes.failure')
      set_categories
      render :action => 'edit'
    end
  end

  def rollback
    version = params[:wikipage][:version].to_i
    if @wikipage.version != version and @wikipage.revert_to(version)
      trigger_event(@wikipage, :rolledback)
      flash[:notice] = t(:'adva.wikipage.flash.rollback.success', :version => params[:version])
      redirect_to edit_admin_wikipage_url
    else
      flash.now[:error] = t(:'adva.wikipage.flash.rollback.failure', :version => params[:version])
      redirect_to edit_admin_wikipage_url
    end
  end

  def destroy
    if @wikipage.destroy
      trigger_events(@wikipage)
      flash[:notice] = t(:'adva.wikipage.flash.destroy.success')
      redirect_to admin_wikipages_url
    else
      flash[:error] = t(:'adva.wikipage.flash.destroy.failure')
      render :action => 'show'
    end
  end

  private

    def set_menu
      @menu = Menus::Admin::Wiki.new
    end

    def set_section
      super
    end

    def set_wikipage
      @wikipage = @section.wikipages.find(params[:id])
      @wikipage.revert_to params[:version] if params[:version]
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def set_wikipage_param(key, value)
      params[:wikipage] ||= {}
      params[:wikipage][key] = value
    end

    def optimistic_lock
      return unless params[:wikipage]
      
      unless updated_at = params[:wikipage].delete(:updated_at)
        # TODO raise something more explicit here
        raise t(:'adva.wiki.optimistic_lock.exception.missing_timestamp')
      end
      
      # We parse the timestamp of wikipage too so we can get rid of those microseconds postgresql adds
      if @wikipage.updated_at && (Time.zone.parse(updated_at) != Time.zone.parse(@wikipage.updated_at.to_s))
        flash[:error] = t(:'adva.wiki.flash.optimistic_lock.failure')
        render :action => :edit
      end
    end
end
