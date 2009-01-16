require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumsController do
  include SpecControllerHelper
  
  before :each do
    Site.delete_all
    @site  = Factory :site
    @user  = Factory :user
    @album = Factory :album, :site => @site
    @photo = Factory :photo, :section => @album, :author => @user, :published_at => Time.now
    @set   = Factory :set, :section => @album
    
    @user.roles << Rbac::Role.build(:admin, :context => @site)
    @photo.tags << Tag.create!(:name => 'tagged')
    @photo.sets << @set
    
    Site.stub!(:find_by_host).and_return @site
    @site.sections.stub!(:root).and_return @album
    @site.sections.stub!(:find).and_return @album
    @album.stub!(:accept_comments?).and_return true
    controller.stub!(:current_user).and_return @user
  end
  
  it "is kind of base_controller" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, "/albums" }
    it_assigns :section
    it_assigns :photos
    it_gets_page_cached
  end
  
  describe "GET to show" do
    act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}" }
    it_assigns :section
    it_assigns :photo
      
    describe "when the photo is published" do
      it_renders_template :show
    end

    describe "when the photo is not published" do
      before :each do
        @photo.stub!(:published_at).and_return nil
        @album.photos.stub!(:find).and_return @photo
      end
    
      describe "and the user has :update permissions" do
        it_renders_template :show
        it "skips caching for the rendered page" do
          act!
          controller.skip_caching?.should be_true
        end
      end
    
      describe "and the user does not have :update permissions" do
        before :each do
          controller.stub!(:current_user).and_return stub_model(User, :has_role? => false)
        end
        it_redirects_to { album_path }
      end
    end
  end
  
  describe "Atom feeds" do
    # describe "GET to /albums/1.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}.atom" }
    #   it_renders_template 'index', :format => :atom
    #   it_gets_page_cached
    # end
    # 
    # describe "GET to /albums/1/tags/tagged.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}/tags/tagged.atom" }
    #   it_renders_template 'index', :format => :atom
    #   it_gets_page_cached
    # end
    # 
    # describe "GET to /albums/1/sets/summer.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}/sets/summer.atom" }
    #   it_renders_template 'index', :format => :atom
    #   it_gets_page_cached
    # end
    # 
    # describe "GET to /albums/1/photos/1.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}.atom" }
    #   it_renders_template 'comments/comments', :format => :atom
    #   it_gets_page_cached
    # end
    # 
    # describe "GET to /albums/1/comments.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}/comments.atom" }
    #   it_renders_template 'comments/comments', :format => :atom
    #   it_gets_page_cached
    # end
    # 
    # describe "GET to /albums/1/photos/1/comments.atom" do
    #   act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}.atom" }
    #   it_renders_template 'comments/comments', :format => :atom
    #   it_gets_page_cached
    # end
  end
end

describe "Album page_caching" do
  include SpecControllerHelper

  describe AlbumsController do
    it "page_caches the :index action" do
      cached_page_filter_for(:index).should_not be_nil
    end

    it "tracks read access for a bunch of models for the :index action page caching" do
      AlbumsController.track_options[:index].should include('@photo', '@photos', '@set', {'@site' => :tag_counts, '@section' => :tag_counts})
    end

    it "page_caches the :show action" do
      cached_page_filter_for(:show).should_not be_nil
    end

    it "tracks read access for a bunch of models for the :show action page caching" do
      AlbumsController.track_options[:show].should include('@photo', '@photos', '@set', {"@section" => :tag_counts, "@site" => :tag_counts})
    end

    it "page_caches the comments action" do
      cached_page_filter_for(:comments).should_not be_nil
    end

    it "tracks read access on @commentable for comments action page caching" do
      AlbumsController.track_options[:comments].should include('@commentable')
    end
  end
end