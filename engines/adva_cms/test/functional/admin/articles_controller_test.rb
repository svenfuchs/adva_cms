require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

# With.aspects << :access_control

class AdminArticlesControllerTest < ActionController::TestCase
  tests Admin::ArticlesController

  with_common :is_superuser, [:a_page, :a_blog]

  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  view :form do
    has_tag 'input[name=?]', 'article[title]'
    has_tag 'textarea[name=?]', 'article[body]'

    has_tag 'input[type=checkbox][name=?]', 'article[draft]' do |tags|
      expected = assigns(:article).draft? ? 'checked' : nil
      assert_equal expected, tags.first.attributes['checked']
    end

    has_tag 'select[id=article_author_id]'
    has_tag 'select[name=cl] option[value=?][selected=selected]', @controller.params[:cl] || :en

    # FIXME renders checkboxes
    # FIXME renders assets widget
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :get,    "articles",        :action => 'index'
      r.it_maps :get,    "articles/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "articles/new",    :action => 'new'
      r.it_maps :post,   "articles",        :action => 'create'
      r.it_maps :get,    "articles/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "articles/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "articles/1",      :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :show, :article

    with :access_granted do
      with "in single-article-mode", :in => :a_page do
        before { @section.single_article_mode = true; @section.save! }

        it_assigns :article
        it_renders :template, lambda { "admin/articles/edit" }
      end

      with "not in single-article-mode" do
        it_assigns :articles
        it_renders :template, lambda { "admin/articles/index" }

        it "displays an articles list" do
          # has_tag 'th[class=total]', /total: \d article(s)?/i
          has_tag 'table[id=articles] tr td a[href=?]',
                    edit_admin_article_path(@site, @section, assigns(:articles).first),
                    assigns(:articles).first.title
          # FIXME if article has comments enabled: shows comments counts, otherwise doesn't
        end
      end
    end
  end

  describe "GET to :show" do
    action { get :show, @params }

    with :a_published_article do
      before { @params = default_params.merge(:id => @article.id) }

      it_guards_permissions :show, :article

      with :access_granted do
        it "previews the article in the frontend layout" do
          it_assigns :article => :not_nil
          it_renders :template, lambda { "#{@section.type.tableize}/articles/show" }
        end

        with "given a :version param" do
          before do
            @params.merge! :version => 1
            @article.update_attributes :title => 'new title'
          end

          it "reverts the article to the given version" do
            assigns(:article).version.should == 1
          end
        end
      end

      # FIXME add view assertions
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }
    it_guards_permissions :create, :article

    with :access_granted do
      it_assigns :site, :section, :article
      it_renders :template, :new

      has_form_posting_to admin_articles_path do
        shows :form
      end
    end
  end

  describe "GET to :new for :de" do
    after do
      Article.locale = I18n.locale
    end

    action { get :new, default_params.merge( :cl => 'de') }
    it_guards_permissions :create, :article

    with :access_granted do
      it_assigns :site, :section, :article
      it_renders :template, :new

      has_form_posting_to admin_articles_path do
        shows :form
      end
    end
  end

  describe "POST to :create" do
    action do
      Article.with_observers :article_sweeper do
        post :create, default_params.merge(@params)
      end
    end

    with :valid_article_params do
      it_guards_permissions :create, :article

      with :access_granted do
        it_assigns :site, :section, :article
        it_changes 'Article.count' => 1
        it_triggers_event :article_created
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to { edit_admin_article_url(@site.id, @section.id, assigns(:article).id) }
        it_sweeps_page_cache :by_reference => :section

        it "associates the new Article to the current site" do
          assigns(:article).reload.site.should == @site
        end

        it "associates the new Article to the current page" do
          assigns(:article).reload.section.should == @section
        end
      end
    end

    with :invalid_article_params do
      with :access_granted do
        it_assigns :site, :section, :article
        it_does_not_change 'Article.count'
        it_does_not_trigger_any_event
        it_renders :template, :new
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_sweep_page_cache
      end
    end
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @article.id) }

    with [:a_published_article, :an_unpublished_article] do
      it_guards_permissions :update, :article

      with :access_granted do
        it_assigns :site, :section, :article
        it_renders :template, :edit
      end

      has_form_putting_to admin_article_path do
        shows :form
        # assert that the taglist field works when taglist contains double quotes
      end
    end
  end

  describe "GET to :edit for :de" do
    after do
      Article.locale = I18n.locale
    end

    action { get :edit, default_params.merge(:id => @article.id, :cl => 'de') }

    with [:a_published_article, :an_unpublished_article] do
      it_guards_permissions :update, :article

      with :access_granted do
        it_assigns :site, :section, :article
        it_renders :template, :edit
      end

      has_form_putting_to admin_article_path do
        shows :form
        # assert that the taglist field works when taglist contains double quotes
      end
    end
  end
  
  describe "PUT to :update" do
    with "incorrect time stamp" do
      action do
        Article.with_observers :article_sweeper do
          params = default_params.merge(@params).merge(:id => @article.id)
          params[:article][:updated_at] = "#{Time.parse('2002-01-01 12:00:00')}"
          put :update, params
        end
      end
      with :a_published_article do
        with :access_granted do
          with :valid_article_params do
            it_assigns :site, :section, :article
            it_assigns_flash_cookie :error => :not_nil
            it_renders :template, :edit
            it_does_not_trigger_any_event
            it_does_not_sweep_page_cache
          end
        end
      end
    end
  end

  describe "PUT to :update" do
    action do
      Article.with_observers :article_sweeper do
        params = default_params.merge(@params).merge(:id => @article.id)
        params[:article][:title] = "#{@article.title} was changed" if params[:article][:title].present?
        params[:article][:updated_at] = "#{@article.updated_at}"
        put :update, params
      end
    end

    with :a_published_article do
      with "no version param" do
        with :access_granted do
          with :valid_article_params do
            it_guards_permissions :update, :article

            it_assigns :site, :section, :article
            it_updates :article
            it_redirects_to { edit_admin_article_url(@site, @section, @article) }
            it_assigns_flash_cookie :notice => :not_nil
            it_triggers_event :article_updated
            it_sweeps_page_cache :by_reference => :article

            # FIXME why doesn't this work here?
            # it_versions :article, :with => :save_revision_param
            with(:save_revision_param)    { it_versions :article }
            with(:no_save_revision_param) { it_does_not_version :article }
          end
          
          with :invalid_article_params do
            it_assigns :site, :section, :article
            it_renders :template, :edit
            it_assigns_flash_cookie :error => :not_nil
            it_does_not_trigger_any_event
            it_does_not_sweep_page_cache
          end
        end
      end

      with "version param set to 1" do
        before { @params = default_params.merge(:article => {:version => "1"}) }
      
        with "the article being versioned (succeeds)" do
          before { @article.update_attributes(:title => "#{@article.title} was changed") }
      
          it_rollsback :article, :to => 1
          it_triggers_event :article_rolledback
          it_assigns_flash_cookie :notice => :not_nil
          it_redirects_to { edit_admin_article_url(@site, @section, @article) }
          it_sweeps_page_cache :by_reference => :article
        end
      
        with "the article not being versioned (fails)" do
          it_does_not_rollback :article
          it_does_not_trigger_any_event
          it_assigns_flash_cookie :error => :not_nil
          it_redirects_to { edit_admin_article_url(@site, @section, @article) }
          it_does_not_sweep_page_cache
        end
      end
    end
  end

  describe "DELETE to :destroy" do
    with :a_published_article do
      action do
        Article.with_observers :article_sweeper do
          delete :destroy, default_params.merge(:id => @article.id)
        end
      end

      it_guards_permissions :destroy, :article

      with :access_granted do
        it_assigns :site, :section, :article
        it_destroys :article
        it_triggers_event :article_deleted
        it_sweeps_page_cache :by_reference => :article
        # TODO redirect? flash?
      end
    end
  end
end