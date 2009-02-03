class Admin::WikipagesController < Admin::BaseController
  layout "admin"
  helper :assets, :roles, :'admin/comments'

  before_filter :set_section
  before_filter :set_wikipage, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]
  before_filter :params_author, :only => [:create, :update]

  cache_sweeper :wikipage_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  widget :sub_nav, :partial => 'widgets/admin/sub_nav',
                   :only  => { :controller => ['admin/wikipages'] }

  guards_permissions :wikipage

  def index
    @wikipages = @section.wikipages.paginate :page => current_page, :per_page => params[:per_page]
  end

  def new
    @wikipage = @section.wikipages.build(:title => @section.wikipages.empty? ? 'Home' : nil)
  end

  def create
    @wikipage = @section.wikipages.create(params[:wikipage])
    if @wikipage.valid?
      trigger_events @wikipage
      flash[:notice] = t(:'adva.wikipage.flash.create.succsess')
      redirect_to edit_admin_wikipage_path(@site, @section, @wikipage)
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
      trigger_events @wikipage
      flash[:notice] = t(:'adva.wikipage.flash.update_attributes.success')
      redirect_to edit_admin_wikipage_path
    else
      flash[:error] = t(:'adva.wikipage.flash.update_attributes.failure')
      set_categories
      render :action => 'edit'
    end
  end

  def rollback
    version = params[:wikipage][:version].to_i
    if @wikipage.version != version and @wikipage.revert_to!(version)
      trigger_event @wikipage, :rolledback
      flash[:notice] = t(:'adva.wikipage.flash.rollback.success', :version => params[:version])
      redirect_to edit_admin_wikipage_path
    else
      flash.now[:error] = t(:'adva.wikipage.flash.rollback.failure', :version => params[:version])
      redirect_to edit_admin_wikipage_path
    end
  end

  def destroy
    if @wikipage.destroy
      trigger_events @wikipage
      flash[:notice] = t(:'adva.wikipage.flash.destroy.success')
      redirect_to admin_wikipages_path
    else
      flash[:error] = t(:'adva.wikipage.flash.destroy.failure')
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
      params[:wikipage] ||= {}
      author = params[:wikipage][:author] ? User.find(params[:wikipage][:author]) : current_user
      set_wikipage_param(:author, author) or raise t(:'adva.wikipage.exception.author_and_current_user_not_set')
    end

    def set_wikipage_param(key, value)
      params[:wikipage] ||= {}
      params[:wikipage][key] = value
    end
end

