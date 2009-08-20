class Admin::CategoriesController < Admin::BaseController
  before_filter :set_category, :only => [:edit, :update, :destroy]

  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :category, :update => :update_all

  def new
    @category = @section.categories.build
  end

  def create
    @category = @section.categories.build params[:category]
    if @category.save
      flash[:notice] = t(:'adva.categories.flash.create.success')
      redirect_to admin_categories_url
    else
      flash.now[:error] = t(:'adva.categories.flash.create.failure')
      render :action => "new"
    end
  end

  def update
    if @category.update_attributes params[:category]
      flash[:notice] = t(:'adva.categories.flash.update.success')
      redirect_to edit_admin_category_url
    else
      flash.now[:error] = t(:'adva.categories.flash.update.failure')
      render :action => 'edit'
    end
  end

  def update_all
    # FIXME we currently use :update_all to update the position for a single object
    # instead we should either use :update_all to batch update all objects on this
    # resource or use :update. applies to articles, sections, categories etc.
    @section.categories.update(params[:categories].keys, params[:categories].values)
    @section.categories.update_paths!
    render :text => 'OK'
  end

  def destroy
    if @category.destroy
      flash[:notice] = t(:'adva.categories.flash.destroy.success')
      redirect_to admin_categories_url
    else
      flash.now[:error] = t(:'adva.categories.flash.destroy.failure')
      render :action => 'edit'
    end
  end

  protected

    def set_menu
      @menu = Menus::Admin::Categories.new
    end

    def set_category
      @category = @section.categories.find(params[:id])
    end
end
