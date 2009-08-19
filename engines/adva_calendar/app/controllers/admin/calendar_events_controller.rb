class Admin::CalendarEventsController < Admin::BaseController
  before_filter :set_section
  before_filter :set_event, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit, :create, :update]

  before_filter :params_draft, :only => [:create, :update]
  before_filter :params_published_at, :only => [:create, :update]
  before_filter :params_dates, :only => [:create, :update]
  before_filter :params_category_ids, :only => [:update]

  cache_sweeper :calendar_event_sweeper, :tag_sweeper, :category_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :calendar_event

  def index
    scope = @section.events

    @events = if %w(title body).include?(params[:filter])
      scope.search(params[:query], params[:filter])
    elsif params[:filter] == 'tags' and params[:query].present?
      scope.tagged(params[:query])
    else
      params[:category] ? scope.by_categories(params[:category].to_i) : scope
    end.paginate(:page => params[:page])
  end

  def new
    @event = @calendar.events.build(:start_date => Time.now, :end_date => Time.now + 2.hours)
  end

  def create
    @event = @calendar.events.new(params[:calendar_event])
    if @event.save
      trigger_events @event
      flash[:notice] = t(:'adva.calendar.flash.create.success')
      redirect_to edit_admin_calendar_event_url(@site.id, @section.id, @event.id)
    else
      set_categories
      flash[:error] = t(:'adva.calendar.flash.create.failure')
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @event.attributes = params[:calendar_event]
    if @event.save
      trigger_events @event
      flash[:notice] = t(:'adva.calendar.flash.update.success')
      redirect_to edit_admin_calendar_event_url(@site.id, @section.id, @event.id)
    else
      flash[:error] = t(:'adva.calendar.flash.update.failure')
      render :action => 'edit'
    end
  end

  def destroy
    if @event.destroy
      trigger_events @event
      flash[:notice] = t(:'adva.calendar.flash.destroy.success')
      redirect_to admin_calendar_events_url
    else
      flash[:error] = t(:'adva.calendar.flash.destroy.failure')
      render :action => 'show'
    end
  end

  private
    def set_menu
      @menu = Menus::Admin::Calendar.new
    end

    def set_section
      @calendar = @section = Calendar.find(params[:section_id], :conditions => {:site_id => @site.id})
    end

    def set_event
      @event = @calendar.events.find(params[:id])
    end

    def set_categories
      @categories = @calendar.categories.roots
    end

    def params_category_ids
      default_calendar_event_param(:category_ids, [])
    end

    def params_draft
      set_calendar_event_param(:published_at, nil) if save_draft?
    end

    def params_published_at
      date = Time.extract_from_attributes!(params[:calendar_event], :published_at, :local)
      set_calendar_event_param(:published_at, date) if date && !save_draft?
    end

    def params_dates
      set_calendar_event_param(:start_date, Time.parse(params[:calendar_event][:start_date])) if params[:calendar_event][:start_date].present?
      set_calendar_event_param(:end_date, Time.parse(params[:calendar_event][:end_date])) if params[:calendar_event][:end_date].present?
    end

    def save_draft?
      params[:draft] == '1'
    end

    def set_calendar_event_param(key, value)
      params[:calendar_event] ||= {}
      params[:calendar_event][key] = value
    end

    def default_calendar_event_param(key, value)
      params[:calendar_event] ||= {}
      params[:calendar_event][key] ||= value
    end
end

