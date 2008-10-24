class Admin::WikipagesController < Admin::BaseController
  layout "admin"
  helper :assets, :roles

  before_filter :set_section
  before_filter :set_wikipage, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]
  
  before_filter :params_author, :only => [:create, :update]

  
  widget :menu_section,  :partial => 'widgets/admin/menu_section',
                         :only  => { :controller => ['admin/wikipages'] }

  guards_permissions :wikipage, :except => [:show, :index]

  def index
    @wikipages = @section.wikipages.paginate :page => current_page, :per_page => params[:per_page]
  end
  
  def new
    @wikipage = @section.wikipages.build(:title => 'New wikipage')
  end
  
  def create
    if @wikipage = @section.wikipages.create(params[:wikipage])
      trigger_events @wikipage
      flash[:notice] = "The wikipage has been successfully created."
      redirect_to edit_admin_wikipage_path(@site, @section, @wikipage)
    else
      flash[:error] = "The wikipage could not been created."
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    params[:version] ? rollback : update_attributes
  end

  def update_attributes
    if @wikipage.update_attributes(params[:wikipage])
      trigger_events @wikipage
      flash[:notice] = "The wikipage has been successfully updated."
      redirect_to edit_admin_wikipage_path
    else
      flash[:error] = "The wikipage could not been updated."
      render :action => 'edit'
    end
  end

  def rollback
    if @wikipage.revert_to!(params[:version])
      trigger_events @wikipage, :rolledback
      flash[:notice] = "The wikipage has been rolled back to revision #{params[:version]}"
      redirect_to edit_admin_wikipage_path
    else
      flash.now[:error] = "The wikipage could not be rolled back to revision #{params[:version]}."
      render :action => 'edit'
    end
  end
  
  def destroy
    if @wikipage.destroy
      trigger_events @wikipage
      flash[:notice] = "The wikipage has been deleted."
      redirect_to admin_wikipages_path
    else
      flash[:error] = "The wikipage could not be deleted."
      render :action => 'show'
    end
  end

  private

    def set_section
      super
    end

    def set_wikipage
      @wikipage = @section.wikipages.find params[:id]
      @wikipage.revert_to params[:version] if params[:version]
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def params_author
      return if params[:version]
      author = User.find(params[:wikipage][:author]) || current_user
      set_wikipage_param(:author, author) or raise "author and current_user not set"
    end

    def set_wikipage_param(key, value)
      params[:wikipage] ||= {}
      params[:wikipage][key] = value
    end
end

