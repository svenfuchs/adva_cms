require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PhotosControllerTest < ActionController::TestCase
  tests Admin::PhotosController

  def setup
    super
    stub_paperclip_post_processing!
  end

  view :form do
    has_tag 'input[name=?]', 'photo[title]'
    has_tag 'input[name=?][type="file"]', 'photo[data]'

    has_tag 'input[type=checkbox][name=?]', 'photo[draft]' do |tags|
      expected = assigns(:photo).draft? ? 'checked' : nil
      assert_equal expected, tags.first.attributes['checked']
    end

    has_tag 'select[id=photo_author]'
    has_tag 'select[id=photo_comment_age]'
    has_tag 'input[name=?]', 'photo[tag_list]'

    if @album.sets.present?
      has_tag 'input[name=?]', 'photo[set_ids][]'
    end
  end

  with_common :is_superuser, :a_site_with_album

  def default_params
    { :site_id => @site.id, :section_id => @album.id }
  end

  def valid_post_params
    {:photo => { :title => 'another photo',
                 :data => File.new(File.dirname(__FILE__) + '/../../fixtures/rails.png'),
                 :author => "#{@user.id}" }}
  end

  def valid_form_params
    default_params.merge(valid_post_params)
  end

  def invalid_form_params
    invalid_post_params = valid_post_params
    invalid_post_params[:photo][:title] = nil
    default_params.merge(invalid_post_params)
  end

  test "is kind of admin::base_controller" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "GET to index" do
    action { get :index, default_params }

    it_assigns :photos
    it_renders_template :index
    it_does_not_sweep_page_cache
  end

  describe "GET to new" do
    action { get :new, default_params }

    it_assigns :photo => Photo
    it_assigns :sets
    it_renders_template :new
    it_does_not_sweep_page_cache

    it "has a post form" do
      has_form_posting_to admin_photos_path(@site, @album) do
        shows :form
      end
    end
  end

  describe "POST to create" do
    action { post :create, valid_form_params }

    it_assigns :photo => Photo
    it_assigns :sets
    it_redirects_to { edit_admin_photo_url(@site, @album, Photo.find_by_title('another photo')) }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_section => :section, :by_reference => :photo
  end

  describe "POST to create, with invalid parameters" do
    action { post :create, invalid_form_params }

    it_assigns :photo => Photo
    it_assigns :sets
    it_renders_template :new
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_sweep_page_cache
  end

  describe "GET to edit" do
    action { get :edit, default_params.merge(:id => @photo.id) }

    it_assigns :photo
    it_assigns :sets
    it_renders_template :edit
    it_does_not_sweep_page_cache

    it "has a put form" do
      has_form_putting_to admin_photo_path(@site, @album, @photo) do
        shows :form
      end
    end
  end

  describe "PUT to update" do
    action { put :update, valid_form_params.merge(:id => @photo.id) }

    it_assigns :photo
    it_assigns :sets
    it_redirects_to { edit_admin_photo_url(@site, @album, @photo) }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_reference => :photo
  end

  describe "PUT to update, with invalid parameters" do
    action { put :update, invalid_form_params.merge(:id => @photo.id) }

    it_assigns :photo
    it_assigns :sets
    it_renders_template :edit
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_sweep_page_cache
  end

  describe "DELETE to destroy" do
    action { delete :destroy, default_params.merge(:id => @photo.id) }

    it_assigns :photo
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { admin_photos_url(@site, @album) }
    it_sweeps_page_cache :by_reference => :photo
  end
end