class EventsController < BaseController
  before_filter :set_section
  before_filter :set_tags, :only => [:index]
  before_filter :set_event, :except => [:index, :new]
  before_filter :set_events, :only => [:index]
  before_filter :set_author_params, :only => [:create, :update]

  authenticates_anonymous_user
  acts_as_commentable

  caches_page_with_references :index, :show, :track => ['@event', '@events', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :event_sweeper, :tag_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :event, :except => [:index, :show]

  def index
    respond_to do |format|
      format.html { render }
      format.atom { render :layout => false }
    end
  end

  def new
    @event = Event.new(:title => 'a new event')
  end

  def show
    if !@event.new_record?
      render
    elsif has_permission? :create, :event
      render :action => :new, :skip_caching => true
    else
      redirect_to_login 'You need to be logged in to edit this page.'
    end
  end

  def diff
    @diff = @event.diff_against_version params[:diff_version]
  end

  def create
    if @event = @section.events.create(params[:event])
      trigger_events @event
      flash[:notice] = "The event has been calendared."
      redirect_to calendar_event_path(:section_id => @section, :id => @event.permalink)
    else
      flash[:error] = "The event could not be saved."
      render :action => :new
    end
  end

  def edit
  end

  def update
    params[:version] ? rollback : update_attributes
  end

  def update_attributes
    if @event.update_attributes(params[:event])
      trigger_events @event
      flash[:notice] = "The event has been updated."
      redirect_to calendar_event_path(:section_id => @section, :id => @event.permalink)
    else
      flash.now[:error] = "The event could not be updated."
      render :action => :edit
    end
  end


  def destroy
    if @event.destroy
      trigger_events @event
      flash[:notice] = 'Event has been destroyed.'
      redirect_to calendar_path(@section)
    else
      flash.now[:error] = "The event could not be deleted."
      render :action => :show
    end
  end

  private

    def set_section; super(Calendar); end

    def set_event
      @event = @section.events.find params[:id]
      raise "could not find event '#{params[:id]}'" unless @event
    end

    def set_events
      options = { :page => current_page, :tags => @tags }
      source = @category ? @category.contents : @section.events
      @events = source.paginate options
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def set_author_params
      params[:event][:author] = current_user ? current_user : nil if params[:event]
    end

    def current_role_context
      @event || @section
    end
end
