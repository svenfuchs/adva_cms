class Admin::CategoriesController < Admin::BaseController
  before_filter :set_section
  before_filter :set_categories, :only => [:index]
  before_filter :set_category,   :only => [:edit, :update, :destroy]

  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :category

  def index
  end

  def new
    @category = @section.categories.build
  end

  def create
    @category = @section.categories.build params[:category]
    if @category.save
      flash[:notice] = t(:'adva.categories.flash.create.success')
      redirect_to admin_categories_path
    else
      flash.now[:error] = t(:'adva.categories.flash.create.failure')
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @category.update_attributes params[:category]
      flash[:notice] = t(:'adva.categories.flash.update.success')
      redirect_to edit_admin_category_path
    else
      flash.now[:error] = t(:'adva.categories.flash.update.failure')
      render :action => 'edit'
    end
  end

  def update_all
    @section.categories.update(params[:categories].keys, params[:categories].values)
    render :text => 'OK'
  end

  def destroy
    if @category.destroy
      flash[:notice] = t(:'adva.categories.flash.destroy.success')
      redirect_to admin_categories_path
    else
      flash.now[:error] = t(:'adva.categories.flash.destroy.failure')
      render :action => 'edit'
    end
  end

  protected

    def set_menu
      @menu = Menus::Admin::Categories.new
    end

    def set_categories
      @categories = @section.categories.paginate :conditions => {:parent_id => nil}, :page => current_page
    end

    def set_category
      @category = @section.categories.find(params[:id])
    end
end
