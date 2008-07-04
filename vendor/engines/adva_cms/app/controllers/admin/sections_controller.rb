class Admin::SectionsController < Admin::BaseController
  layout "admin"
  
  before_filter :set_section, :only => [:show, :update, :destroy]
  before_filter :normalize_params, :only => :update_all
  
  cache_sweeper :section_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :section, :update => :update_all
  
  def index
  end
  
  def show
  end
  
  def new
    @section = @site.sections.build(:type => Section.types.first)
  end

  def create
    @section = @site.sections.build params[:section]
    if @section.save
      flash[:notice] = "The section has been created."
      redirect_to admin_section_path(:id => @section)
    else
      flash.now[:error] = "The section could not be created."
      render :action => "new"
    end
  end
  
  def edit
  end
 
  def update
    if @section.update_attributes params[:section]
      flash[:notice] = "The section has been updated."
      redirect_to admin_section_path
    else
      flash.now[:error] = "The section could not be updated."
      render :action => 'show'
    end
  end

  def destroy
    if @section.destroy
      flash[:notice] = "The section has been deleted."
      redirect_to new_admin_section_path
    else
      flash.now[:error] = "The section could not be deleted."
      render :action => 'show'
    end
  end
  
  def update_all
    # TODO add a after_move hook to better_nested_set
    # for now we can omit this because this action will only be called when
    # a section actually moves
    # moving = !(params[:sections].values.first.keys & ['left_id', 'parent_id']).empty?
    @site.sections.update(params[:sections].keys, params[:sections].values)
    @site.sections.update_paths! # if moving
    render :text => 'OK'
  end
  
  protected
  
    def set_site
      @site = Site.find(params[:site_id])
    end
  
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
