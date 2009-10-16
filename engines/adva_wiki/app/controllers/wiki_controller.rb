class WikiController < BaseController
  before_filter :set_section
  before_filter :set_category, :only => [:index]
  before_filter :set_categories, :only => [:edit]
  before_filter :set_tags, :only => [:index]
  before_filter :set_wikipage, :except => [:index, :new, :create]
  before_filter :set_wikipages, :only => [:index]
  before_filter :set_author_params, :only => [:create, :update]
  before_filter :optimistic_lock, :only => [:update]
  helper :wiki

  authenticates_anonymous_user

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :index, :show, :comments, 
    :track => ['@wikipage', '@wikipages', '@category', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :wikipage_sweeper, :category_sweeper, :tag_sweeper, :only => [:create, :update, :rollback, :destroy]
  guards_permissions :wikipage, :except => [:index, :show, :diff, :comments], :edit => :rollback

  acts_as_commentable if Rails.plugin?(:adva_comments)

  def index
    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end
  end

  def new
    @wikipage = Wikipage.new(:title => t(:'adva.wiki.new_page_title'))
  end

  def show
    set_categories if @wikipage.new_record?
    if @wikipage.new_record?
      if has_permission?(:create, :wikipage)
        render :action => :new, :skip_caching => true
      else
        redirect_to_login t(:'adva.wiki.redirect_to_login')
      end
    end
  end

  def diff
    @diff = @wikipage.diff_against_version(params[:diff_version])
  end

  def create
    @wikipage = @section.wikipages.build(params[:wikipage])
    if @wikipage.save
      trigger_events(@wikipage)
      flash[:notice] = t(:'adva.wiki.flash.create.success')
      redirect_to wikipage_url(@wikipage)
    else
      flash[:error] = t(:'adva.wiki.flash.create.failure')
      render :action => :new
    end
  end

  def edit
  end

  def update
    params[:wikipage] ||= {}
    params[:wikipage][:version] ? rollback : update_attributes
  end

  def update_attributes
    if @wikipage.update_attributes(params[:wikipage])
      trigger_event(@wikipage, :updated)
      flash[:notice] = t(:'adva.wiki.flash.update_attributes.success')
      redirect_to wikipage_url(@wikipage)
    else
      flash.now[:error] = t(:'adva.wiki.flash.update_attributes.failure')
      render :action => :edit
    end
  end

  def rollback
    version = params[:wikipage][:version].to_i
    if @wikipage.version != version and @wikipage.revert_to(version)
      trigger_event(@wikipage, :rolledback)
      flash[:notice] = t(:'adva.wiki.flash.rollback.success', :version => version)
      redirect_to wikipage_url(@wikipage)
    else
      flash.now[:error] = t(:'adva.wiki.flash.rollback.failure', :version => version)
      redirect_to wikipage_url(@wikipage, :version => @wikipage.version)
      # render :action => :edit
    end
  end

  def destroy
    if @wikipage.destroy
      trigger_events(@wikipage)
      flash[:notice] = t(:'adva.wiki.flash.destroy.success')
      redirect_to wiki_url(@section)
    else
      flash.now[:error] = t(:'adva.wiki.flash.destroy.failure')
      render :action => :show
    end
  end

  private

    def set_section; super(Wiki); end

    def set_wikipage
      # TODO do not initialize a new wikipage on :edit and :update actions
      @wikipage = @section.wikipages.find_or_initialize_by_permalink(params[:id] || 'home')
      raise t(:'adva.wiki.exception.could_not_find_wikipage_by_permalink', :id => params[:id]) if params[:show] && @wikipage.new_record?
      @wikipage.revert_to(params[:version]) if params[:version]
      @wikipage.author = current_user || User.anonymous if @wikipage.new_record? ||
        params[:action] == 'edit'
    end

    def set_wikipages
      scope = @category ? @category.contents : @section.wikipages
      scope = scope.tagged(@tags) if @tags.present?
      @wikipages = scope.paginate(:page => current_page)
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find(params[:category_id])
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def set_commentable
      set_wikipage if params[:id]
      @commentable = @wikipage || super
    end

    def set_author_params
      params[:wikipage][:author] = current_user ? current_user : nil if params[:wikipage]
    end

    def optimistic_lock
      return unless params[:wikipage]

      unless updated_at = params[:wikipage].delete(:updated_at)
        # TODO raise something more explicit here
        raise t(:'adva.wiki.exception.missing_timestamp')
      end

      # We parse the timestamp of wikipage too so we can get rid of those microseconds postgresql adds
      if @wikipage.updated_at && (Time.zone.parse(updated_at) != Time.zone.parse(@wikipage.updated_at.to_s))
        flash[:error] = t(:'adva.wiki.flash.optimistic_lock.failure')
        render :action => :edit
      end
    end

    def current_resource
      @wikipage || @section
    end
end
