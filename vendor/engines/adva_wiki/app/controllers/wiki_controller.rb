class WikiController < BaseController
  before_filter :set_category, :set_tags, :only => [:index]
  before_filter :set_categories, :only => [:edit]
  before_filter :set_tags, :only => [:index]
  before_filter :set_wikipage, :except => [:index]
  before_filter :set_wikipages, :only => [:index]
  before_filter :set_author_params, :only => [:create, :update]
  before_filter :optimistic_lock, :only => [:update]

  authenticates_anonymous_user
  guards_permissions :wikipage, :except => [:index, :show, :diff]
  acts_as_commentable
  
  caches_page_with_references :index, :show, :track => ['@wikipage', '@wikipages', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :wikipage_sweeper, :category_sweeper, :tag_sweeper, :only => [:create, :update, :rollback, :destroy]
  
  helper_method :collection_title
  
  def index
    respond_to do |format| 
      format.html { render @section.render_options } 
      format.atom { render :layout => false }
    end    
    # TODO @section.render_options.update(:action => 'show')
  end
  
  def show
    set_categories if @wikipage.new_record?
    if !@wikipage.new_record?
      render @section.render_options
    elsif has_permission? :create, :wikipage
      render :action => :new, :skip_caching => true
    else
      redirect_to_login 'You need to be logged in to edit this page.'
    end
    # options = @wikipage.new_record? ? {:action => :new} : @section.render_options
    # render options
  end
  
  def diff
    @diff = @wikipage.diff_against_version params[:diff_version]
  end
  
  def create
    if @wikipage = @section.wikipages.create(params[:wikipage])
      flash[:notice] = "The wikipage has been saved."
      redirect_to wikipage_path(:section_id => @section, :id => @wikipage.permalink)
    else
      flash[:error] = "The wikipage could not be saved."
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    rollback and return if params[:version]
    if @wikipage.update_attributes params[:wikipage]
      flash[:notice] = "The wikipage has been updated."
      redirect_to wikipage_path(:section_id => @section, :id => @wikipage.permalink)
    else
      flash.now[:error] = "The wikipage could not be updated."
      render :action => :edit
    end
  end

  def rollback
    @wikipage.revert_to(params[:version])
    @wikipage.save
    flash[:notice] = "The wikipage has been rolled back to revision #{params[:version]}"
    redirect_to wikipage_path(:section_id => @section, :id => @wikipage.permalink)
  end

  def destroy
    if @wikipage.destroy
      flash[:notice] = 'Wikipage destroyed.'
      redirect_to wiki_path(@section)
    else
      flash.now[:error] = "The wikipage could not be deleted."
      render :action => :show
    end
  end
  
  private
  
    def collection_title
      title = []      
      title << "about #{@category.title}" if @category
      title << "tagged #{@tags.to_sentence}" if @tags
      title.empty? ? 'All pages' : 'Pages ' + title.join(', ')
    end  

    def set_section
      super 
      raise SectionRoutingError.new("Section must be a Wiki: #{@section.inspect}") unless @section.is_a? Wiki
    end
  
    def set_wikipage
      # TODO do not initialize a new wikipage on :edit and :update actions
      @wikipage = @section.wikipages.find_or_initialize_by_permalink params[:id] || 'home'
      raise "could not find wikipage by permalink '#{params[:id]}'" if params[:show] && @wikipage.new_record?
      @wikipage.revert_to(params[:version]) if params[:version]
      @wikipage.author = current_user || Anonymous.new if @wikipage.new_record? || params[:action] == 'edit'
    end
    
    def set_wikipages
      options = { :page => current_page, :tags => @tags }
      source = @category ? @category.contents : @section.wikipages
      @wikipages = source.paginate options
    end
    
    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id] 
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
      updated_at = params[:wikipage].delete(:updated_at)
      unless updated_at
        raise "Can not update wikipage: timestamp missing. Please make sure that your form has a hidden field: updated_at." 
      end
      if @wikipage.updated_at && (Time.zone.parse(updated_at) != @wikipage.updated_at)
        flash[:error] = "In the meantime this wikipage has been updated by someone else. Please resolve any conflicts."
        # TODO filter_chain has been halted because of the rendering, so we have 
        # to call this manually ... which is stupid. Maybe an around_filter
        # would be the better idea in CacheableFlash?
        write_flash_to_cookie 
        render :action => :edit
      end
    end
    
    def current_role_context
      @wikipage || @section
    end
end