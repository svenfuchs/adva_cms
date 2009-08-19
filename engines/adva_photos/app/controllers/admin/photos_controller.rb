class Admin::PhotosController < Admin::BaseController
  helper 'admin/comments'

  before_filter :set_section
  before_filter :set_sets,            :only => [:new, :edit, :create, :update]
  before_filter :set_photos,          :only => :index
  before_filter :set_photo,           :only => [:destroy, :edit, :update]
  before_filter :params_author,       :only => [:create, :update]
  before_filter :params_draft,        :only => [:create, :update]
  before_filter :params_published_at, :only => [:create, :update]
  before_filter :params_set_ids,      :only => :update

  cache_sweeper :photo_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  guards_permissions :photo

  def index
  end

  def new
    @photo = @section.photos.build(:comment_age => @section.comment_age)
  end

  def edit
  end

  def create
    @photo = @section.photos.build(params[:photo])

    if @photo.save
      flash[:notice] = t(:'adva.photos.flash.photo.create.success')
      redirect_to edit_admin_photo_url(@site, @section, @photo)
    else
      flash[:error] = t(:'adva.photos.flash.photo.create.failure')
      render :action => 'new'
    end
  end

  def update
    if @photo.update_attributes(params[:photo])
      flash[:notice] = t(:'adva.photos.flash.photo.update.success')
      redirect_to edit_admin_photo_url(@site, @section, @photo)
    else
      set_photo
      flash[:error] = t(:'adva.photos.flash.photo.update.failure')
      render :action => 'edit'
    end
  end

  def destroy
    @photo.destroy
    flash[:notice] = t(:'adva.photos.flash.photo.destroy.success')
    redirect_to admin_photos_url(@site, @section)
  end

  protected

    def set_menu
      @menu = Menus::Admin::Photos.new
    end

    def params_author
      author = User.find(params[:photo][:author]) || current_user
      set_photo_param(:author, author) or raise t(:'adva.photos.params.author')
    end

    def params_draft
      set_photo_param(:published_at, nil) if save_draft?
    end

    def params_published_at
      date = Time.extract_from_attributes!(params[:photo], :published_at, :local)
      set_photo_param(:published_at, date) if date && !save_draft?
    end

    def params_set_ids
      default_photo_param(:set_ids, [])
    end

    def save_draft?
      @save_draft ||= params[:photo].delete(:draft)
      @save_draft == '1'
    end

    def set_photo_param(key, value)
      params[:photo] ||= {}
      params[:photo][key] = value
    end

    def default_photo_param(key, value)
      params[:photo] ||= {}
      params[:photo][key] ||= value
    end

    def set_photos
      @photos = @section.photos.paginate(:page => params[:page], :order => 'created_at DESC')
    end

    def set_photo
      @photo = @section.photos.find(params[:id])
    end

    def set_sets
      @sets = @section.sets.roots
    end
end