class Admin::SetsController < Admin::BaseController
  before_filter :set_set, :only => [:edit, :update, :destroy]

  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :category, :update => :update_all

  def new
    @set = @section.sets.build
  end

  def create
    @set = @section.sets.build(params[:set])
    if @set.save
      flash[:notice] = t(:'adva.photos.flash.set.create.success')
      redirect_to admin_sets_url(@site, @section)
    else
      flash[:error] = t(:'adva.photos.flash.set.create.failure')
      render :action => :new
    end
  end

  def update
    if @set.update_attributes(params[:set])
      flash[:notice] = t(:'adva.photos.flash.set.update.success')
      redirect_to admin_sets_url(@site, @section)
    else
      flash[:error] = t(:'adva.photos.flash.set.update.failure')
      render :action => :edit
    end
  end

  def update_all
    # FIXME we currently use :update_all to update the position for a single object
    # instead we should either use :update_all to batch update all objects on this
    # resource or use :update. applies to articles, sections, categories etc.
    @section.sets.update(params[:sets].keys, params[:sets].values)
    @section.sets.update_paths!
    render :text => 'OK'
  end

  def destroy
    @set.destroy
    flash[:notice] = t(:'adva.photos.flash.set.destroy.success')
    redirect_to admin_sets_url(@site, @section)
  end

  protected

    def set_menu
      @menu = Menus::Admin::Sets.new
    end

    def set_set
      @set = @section.sets.find(params[:id])
    end
end