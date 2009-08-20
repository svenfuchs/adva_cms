require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

# FIXME should also test comments on section articles and wikipages

class CommentsControllerTest < ActionController::TestCase
  with_common :a_blog, :a_published_article, :an_approved_comment, :is_superuser

  def default_params
    { :comment => { :commentable_type => 'Article', :commentable_id => @article.id } }
  end

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  describe "routing" do
    it_maps :get,    'comments',         :action => 'index'
    it_maps :get,    'comments/new',     :action => 'new'
    it_maps :post,   'comments/preview', :action => 'preview'
    it_maps :post,   'comments',         :action => 'create'
    it_maps :get,    'comments/1',       :action => 'show',    :id => '1'
    it_maps :get,    'comments/1/edit',  :action => 'edit',    :id => '1'
    it_maps :put,    'comments/1',       :action => 'update',  :id => '1'
    it_maps :delete, 'comments/1',       :action => 'destroy', :id => '1'
  end

  describe "GET to :show" do
    action { get :show, :id => @comment.id }
    it_guards_permissions :show, :comment

    with :access_granted do
      it_assigns :section, :comment, :commentable
      it_renders :template, :show do
        has_text @comment.body
      end

      # FIXME displays a message when the comment is not approved yet: /under review/
    end
  end

  describe "POST to preview" do
    action { post :preview, default_params.merge(@params || {}) }
    it_guards_permissions :create, :comment

    with :access_granted do
      with :valid_comment_params do
        it_assigns :comment => :not_nil
        it_renders :template, :preview do
          has_text 'the comment body'
        end
      end

      # FIXME
      # with "invalid comment params" do
      # end
    end
  end

  describe "POST to :create" do
    action do
      Comment.with_observers :comment_sweeper do
        post :create, default_params.merge(@params || {})
      end
    end

    it_guards_permissions :create, :comment

    with :access_granted do
      with :valid_comment_params do
        it_assigns :commentable => :article, :comment => :not_nil
        it_saves :comment
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :comment_created
        it_sweeps_page_cache :by_reference => :article
        it_redirects_to { comment_url(assigns(:comment)) }

        # FIXME
        # it "checks the comment's spaminess" do
        #   expect do
        #     url = "http://test.host/sections/1/articles/an-article"
        #     mock(@comment).check_approval(:permalink => url, :authenticated => false)
        #     mock(Article).find { @article }
        #     mock(@article).comments.build { @comment }
        #   end
        # end
      end

      with :invalid_comment_params do
        it_renders :template, :show
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
  end

  describe "PUT to :update" do
    action do
      Comment.with_observers :comment_sweeper do
        post :update, (@params || {}).merge(:id => @comment.id)
      end
    end

    it_guards_permissions :update, :comment

    with :access_granted do
      with "valid comment params" do
        before { @params = { :comment => { :body => 'the updated comment body' } } }

        it_updates :comment
        it_redirects_to { comment_url(assigns(:comment)) }
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :comment_updated
        it_sweeps_page_cache :by_reference => :article
      end

      with :invalid_comment_params do
        it_does_not_update :comment
        it_renders_template :show
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
  end

  describe "DELETE to :destroy" do
    action do
      Comment.with_observers :comment_sweeper do
        delete :destroy,:id => @comment.id
      end
    end
    it_guards_permissions :destroy, :comment

    with :access_granted do
      it_assigns :comment
      it_destroys :comment
      it_triggers_event :comment_deleted
      it_redirects_to { '/' }
      it_assigns_flash_cookie :notice => :not_nil
      it_sweeps_page_cache :by_reference => :article
    end
  end
end