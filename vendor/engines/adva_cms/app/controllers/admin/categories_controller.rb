class Admin::CategoriesController < Admin::BaseController
  before_filter :set_section
  before_filter :set_categories, :only => [:index]
  before_filter :set_category,   :only => [:edit, :update, :destroy]
  
  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :category

  def new
    @category = @section.categories.build
  end

  def create    
    @category = @section.categories.build params[:category]
    if @category.save
      flash[:notice] = "The category has been saved."
      redirect_to admin_categories_path
    else
      flash.now[:error] = "The category could not be created."
      render :action => "new"
    end
  end
  
  def update
    if @category.update_attributes params[:category]
      flash[:notice] = "The category has been updated."
      redirect_to edit_admin_category_path
    else
      flash.now[:error] = "The category could not be updated."
      render :action => 'edit'
    end
  end
  
  def update_all
    @section.categories.update(params[:categories].keys, params[:categories].values)
    render :text => 'OK'
  end

  def destroy
    if @category.destroy
      flash[:notice] = "The category has been deleted."
      redirect_to admin_categories_path
    else
      flash.now[:error] = "The category could not be deleted."
      render :action => 'edit'
    end
  end
  
  protected
  
    def set_section
      @section = @site.sections.find(params[:section_id])
    end   
    
    def set_categories
      @categories = @section.categories.paginate :conditions => {:parent_id => nil}, :page => current_page
    end
    
    def set_category
      @category = @section.categories.find(params[:id])
    end
end
