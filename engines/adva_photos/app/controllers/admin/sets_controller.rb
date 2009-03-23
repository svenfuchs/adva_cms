class Admin::SetsController < Admin::BaseController
  content_for :'main_right', :sets_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.sets.actions').render(self)
  end

  before_filter :set_sets,  :only => :index
  before_filter :set_set,   :only => [:edit, :update, :destroy]
  
  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :category
  
  def index
  end
  
  def new
    @set = @section.sets.build
  end
  
  def create
    @set = @section.sets.build params[:set]
    
    if @set.save
      flash[:notice] = t(:'adva.photos.flash.set.create.success')
      redirect_to admin_sets_path(@site, @section)
    else
      flash[:error] = t(:'adva.photos.flash.set.create.failure')
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @set.update_attributes(params[:set])
      flash[:notice] = t(:'adva.photos.flash.set.update.success')
      redirect_to admin_sets_path(@site, @section)
    else
      flash[:error] = t(:'adva.photos.flash.set.update.failure')
      render :action => :edit
    end
  end
  
  def destroy
    @set.destroy
    flash[:notice] = t(:'adva.photos.flash.set.destroy.success')
    redirect_to admin_sets_path(@site, @section)
  end
  
  protected
    def set_sets
      @sets = @section.sets.paginate :conditions => {:parent_id => nil}, :page => current_page
    end
    
    def set_set
      @set = @section.sets.find params[:id]
    end
end