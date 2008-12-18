class Admin::SetsController < Admin::BaseController
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
      flash[:notice] = "Set was successfully saved!"
      redirect_to admin_sets_path(@site, @section)
    else
      flash[:error] = "Set save failed."
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @set.update_attributes(params[:set])
      flash[:notice] = "Set was successfully updated!"
      redirect_to admin_sets_path(@site, @section)
    else
      flash[:error] = "Set update failed."
      render :action => :edit
    end
  end
  
  def destroy
    @set.destroy
    flash[:notice] = "Set was successfully removed!"
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