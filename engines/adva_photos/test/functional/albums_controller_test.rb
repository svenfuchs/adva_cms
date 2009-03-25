require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class AlbumsControllerTest < ActionController::TestCase
  tests AlbumsController
  
  with_common :is_user, :a_site_with_album
  
  def default_params
    { :section_id => @album.id }
  end
  
  def photo_params
    default_params.merge(:photo_id => @photo.id)
  end
  
  test "is kind of base_controller" do
    @controller.should be_kind_of(BaseController)
  end
  
  # FIXME GET to index with sets and tags
  
  describe "GET to index" do
    action { get :index, default_params }
    
    it_assigns :section
    it_assigns :photos
    it_renders_template 'albums'
    it_caches_the_page :track => ['@photo', '@photos', '@set', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
  end
  
  describe "GET to show, preview without permissions" do
    with :an_unpublished_photo do
      action { get :show, photo_params }
      
      it_assigns_flash_cookie :error => :not_nil
      it_redirects_to 'an-album'
    end
  end
  
  describe "GET to show, preview with permissions" do
    with :is_superuser, :an_unpublished_photo do
      action { get :show, photo_params }
      
      it_assigns :section
      it_assigns :photo
      it_renders_template 'show'
      it_does_not_cache_the_page
    end
  end
  
  describe "GET to show" do
    with :a_published_photo do
      action { get :show, photo_params }
      
      it_assigns :section
      it_assigns :photo
      it_renders_template 'show'
      it_caches_the_page :track => ['@photo', '@photos', '@set', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
    end
  end
  
  # FIXME uncomment when we are going to implement an atom feed for photos
  #
  # describe "Atom feeds" do
  #   describe "GET to /albums/1.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}.atom" }
  #     it_renders_template 'index', :format => :atom
  #     it_gets_page_cached
  #   end
  #   
  #   describe "GET to /albums/1/tags/tagged.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}/tags/tagged.atom" }
  #     it_renders_template 'index', :format => :atom
  #     it_gets_page_cached
  #   end
  #   
  #   describe "GET to /albums/1/sets/summer.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}/sets/summer.atom" }
  #     it_renders_template 'index', :format => :atom
  #     it_gets_page_cached
  #   end
  #   
  #   describe "GET to /albums/1/photos/1.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}.atom" }
  #     it_renders_template 'comments/comments', :format => :atom
  #     it_gets_page_cached
  #   end
  #   
  #   describe "GET to /albums/1/comments.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}/comments.atom" }
  #     it_renders_template 'comments/comments', :format => :atom
  #     it_gets_page_cached
  #   end
  #   
  #   describe "GET to /albums/1/photos/1/comments.atom" do
  #     act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}.atom" }
  #     it_renders_template 'comments/comments', :format => :atom
  #     it_gets_page_cached
  #   end
  # end
end