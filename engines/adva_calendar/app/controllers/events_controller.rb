class EventsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles

  before_filter :set_section
  before_filter :set_category, :only => [:index]
  before_filter :set_tags, :only => [:index]
  before_filter :set_event, :except => [:index, :new]

  authenticates_anonymous_user
  acts_as_commentable

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :index, :show, :comments, 
    :track => ['@event', '@events', '@category', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :calendar_event_sweeper, :tag_sweeper, :category_sweeper, :only => [:create, :update, :destroy]

  def index
    scope = @section.events.published
    scope = %w(elapsed recently_added).include?(params[:scope]) ? scope.send(params[:scope]) : scope.upcoming(current_timespan)

    @events = if %w(title body).include?(params[:filter])
      scope.search(params[:query], params[:filter])
    elsif params[:filter] == 'tags' and not params[:query].blank?
      scope.find_tagged_with(params[:query])
    else
      @category ? scope.by_categories(@category.id) : scope
    end.paginate(:page => params[:page])

    respond_to do |format|
      format.js { render :update do |page|
          page.replace  'events', :partial => 'events'
          page.replace 'calendar', :partial => 'calendar'
          page << 'AjaxfiedLaterDude.attachEvents();'
        end
      }
      format.html
      format.ics
    end
  end

  def show
    respond_to do |format|
      format.html
      format.ics
    end
  end

  private

    def set_section; super(Calendar); end

    # future extensions may use something like params[:from] params[:to]
    # but for now we only assume the end of year, month or day
    attr_accessor :current_timespan_format
    helper_method :current_timespan_format
    helper_method :current_timespan
    def current_timespan
      return @current_timespan if @current_timespan
      return @current_timespan = [Date.today, nil] if params[:year].blank?
      y, m, d = params[:year].to_i, params[:month].to_i, params[:day].to_i

      if m == 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year')
        date = Date.new(y)
        @current_timespan = [date, date.end_of_year]
      elsif m > 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month')
        date = Date.new(y, m)
        @current_timespan = [date, date.end_of_month]
      elsif m > 0 and d > 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month_day')
        date = Date.new(y, m, d)
        @current_timespan = [date, date.end_of_day]
      end
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id]
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_event
      @event = @section.events.published.find_by_id params[:id]
      @event ||= @section.events.published.find_by_permalink params[:id]
      if !@event || (@event.draft? && !can_preview?)
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def current_resource
      @event || @section
    end

    def can_preview?
      has_permission?('update', 'article')
    end
end
