class Admin::SectionsController < Admin::BaseController
  content_for :'main_left', :sections_manage, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.sections.manage').render(self)
  end

  content_for :'main_right', :sections_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.sections.actions').render(self)
  end

  before_filter :set_section, :only => [:edit, :update, :destroy]
  before_filter :normalize_params, :only => :update_all

  cache_sweeper :section_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :section, :update => :update_all

  def index
  end

  def new
    @section = @site.sections.build(:type => Section.types.first)
  end

  def create
    @section = @site.sections.build params[:section]
    if @section.save
      flash[:notice] = t(:'adva.sections.flash.create.success')
      redirect_to admin_section_contents_path(@section)
    else
      flash.now[:error] = t(:'adva.sections.flash.update.failure')
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @section.update_attributes params[:section]
      flash[:notice] = t(:'adva.sections.flash.update.success')
      redirect_to edit_admin_section_path(@site, @section)
    else
      flash.now[:error] = t(:'adva.sections.flash.update.failure')
      render :action => 'edit'
    end
  end

  def destroy
    if @section.destroy
      flash[:notice] = t(:'adva.sections.flash.destroy.success')
      redirect_to new_admin_section_path
    else
      flash.now[:error] = t(:'adva.sections.flash.destroy.failure')
      render :action => 'edit'
    end
  end

  def update_all
    # TODO add a after_move hook to better_nested_set
    # for now we can omit this because this action will only be called when
    # a section actually moves
    # moving = !(params[:sections].values.first.keys & ['left_id', 'parent_id']).empty?
    # TODO filter allowed attributes
    # TODO expire cache by site
    @site.sections.update(params[:sections].keys, params[:sections].values)
    @site.sections.update_paths! # if moving
    render :text => 'OK'
  end

  protected

    def set_section
      @section = @site.sections.find(params[:id])
    end

    def normalize_params(hash = nil)
      hash ||= params
      hash.each do |key, value|
        if value.is_a? Hash
          hash[key] = normalize_params(value)
        elsif value == 'null'
          hash[key] = nil
        end
      end
      hash
    end
end
