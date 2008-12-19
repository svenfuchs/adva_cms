require File.dirname(__FILE__) + "/../../test_helper"
  
class AdminArticlesControllerAccessTest < ActionController::TestCase
  tests Admin::ArticlesController

  def setup
    stub(@controller).guard_permission
    stub(@controller).require_authentication
    stub(@controller).current_user{ User.make }
  end
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  describe "GET to :index" do
    action { get :index, default_params }
    
    with :an_empty_section do
    end
   
    with :an_empty_blog do
    end
  end
    
  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @article.id) }
  
    with :published_blog_article do
    end
  
    with :published_section_article do
    end
  end
  
  describe "GET to :new" do
    action { get :new, default_params }
    
    with :an_empty_section, :an_empty_blog do
      # it_guards_permissions :create, :article
    end
  end
  
  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }
    
    with :an_empty_section, :an_empty_blog do
      with :valid_article_params do
        # it_guards_permissions :create, :article
      end
    end
  end
   
  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @article.id) }
  
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        # it_guards_permissions :update, :article
      end
    end
  end
   
  describe "PUT to :update" do
    action do 
      params = default_params.merge(@params).merge(:id => @article.id)
      params[:article][:title] = "#{@article.title} was changed" unless params[:article][:title].blank?
      put :update, params
    end
  
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        # it_guards_permissions :update, :article
      end
    end
  end
  
  describe "DELETE to :destroy" do
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        action { delete :destroy, default_params.merge(:id => @article.id) }
        # it_guards_permissions :destroy, :article
      end
    end
  end
end