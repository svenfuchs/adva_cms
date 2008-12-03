class Admin::EventsController < Admin::BaseController
  layout "admin"
  helper :assets, :roles

  before_filter :set_section
  before_filter :set_event, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]
  
  before_filter :params_author, :only => [:create, :update]

  widget :sub_nav, :partial => 'widgets/admin/sub_nav',
                   :only  => { :controller => ['admin/events'] }

  guards_permissions :calendar_event

  def index
    @events = @section.events.paginate :page => current_page, :per_page => params[:per_page]
  end
  
  def new
    @event = @section.events.build(:title => 'New event')
  end
  
  def create
    if @event = @section.events.create(params[:event])
      trigger_events @event
      flash[:notice] = "The event has been successfully created."
      redirect_to edit_admin_calendar_event_path(@site, @section, @event)
    else
      flash[:error] = "The event could not been created."
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @event.update_attributes(params[:event])
      trigger_events @event
      flash[:notice] = "The event has been successfully updated."
      redirect_to edit_admin_calendar_event_path
    else
      flash[:error] = "The event could not been updated."
      render :action => 'edit'
    end
  end

  def destroy
    if @event.destroy
      trigger_events @event
      flash[:notice] = "The event has been deleted."
      redirect_to admin_calendar_events_path
    else
      flash[:error] = "The event could not be deleted."
      render :action => 'show'
    end
  end

  private

    def set_section
      @section = Calendar.find(params[:section_id], :conditions => {:site_id => @site.id})
    end

    def set_event
      @event = @section.events.find params[:id]
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def params_author
      author = User.find(params[:event][:author]) || current_user
      set_event_param(:author, author) or raise "author and current_user not set"
    end

    def set_event_param(key, value)
      params[:event] ||= {}
      params[:event][key] = value
    end
end

