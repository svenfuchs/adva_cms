require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class WikiControllerTest < ActionController::TestCase
  include WikiHelper
  with_common :is_superuser, :a_wiki, :a_wikipage, :a_wikipage_category

  view :form do
    has_tag 'input[name=?]', 'wikipage[title]'
    has_tag 'textarea[name=?]', 'wikipage[body]'
    # FIXME
    # with the wikipage having categories
    # body.should =~ /content_category_checkbox/
    # with the wikipage having no categories
    # not have_tag('input[type=?][name=?]', 'checkbox', 'wikipage[category_ids][]')
    # with a user currently logged in does not render a name field
    # have_tag('input[name=?]', 'user[name]')
    # with no user currently logged in it renders a name field
    # have_tag('input[name=?]', 'user[name]')
  end

  test "is an BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  { :wiki_path                  => '/a-wiki/wikipages',
    :wiki_category_path         => '/a-wiki/categories/a-category',
    :wiki_tag_path              => '/a-wiki/tags/foo+bar',
    :wiki_feed_path             => '/a-wiki.atom',
    :wiki_category_feed_path    => '/a-wiki/categories/a-category.atom',
    :wiki_tag_feed_path         => '/a-wiki/tags/foo+bar.atom',
    :wiki_comment_feed_path     => '/a-wiki/comments.atom',
    :wikipage_comment_feed_path => '/a-wiki/wikipages/a-wikipage/comments.atom' }.each do |type, path|

    With.share(type) { before { @params = params_from path } }
  end

  describe "GET to :index" do
    action { get :index, @params }

    with [:wiki_path, :wiki_tag_path] do # FIXME, :wiki_category_path
      it_assigns :site, :section, :wikipages
      it_renders :template, :index do
        has_tag '#wikipages tbody tr', :count => @section.wikipages.count
      end

      # FIXME
      # within :no_wikipage do
      #   has_tag '.empty' do
      #     has_text "no wikipages"
      #     has_tag 'a[href=?]', new_wikipage_path(@section)
      #   end
      # end

      it_caches_the_page :track => ['@wikipage', '@wikipages', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]

      it_assigns :category, :in => :'params_from wiki_category_paths'
      it_assigns :tags,     :in => :'params_from wiki_tag_paths'
    end

    with :'wiki_feed_path', [:a_wikipage_category, :wiki_category_feed_path], :wiki_tag_feed_path do
      it_assigns :site, :section, :wikipages
      it_renders :template, :index, :format => :atom
    end
  end

  describe "GET to :show" do
    action { get :show, :section_id => @section, :id => @wikipage.permalink, :version => @version }

    # FIXME with no wikipage it renders the wikipage form

    with [:a_wikipage_category, :no_wikipage_category] do
      it_caches_the_page :track => ['@wikipage', '@wikipages', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
      it_assigns :site, :section, :wikipage

      with "no version param given" do
        it_renders :template, :show do
          has_tag '.entry', 1

          # displays the wikipage's revision number and last author name
          has_text /revision: [\d]+/
          has_text "by: #{@wikipage.author_name}"

          # displays a group of wiki edit links
          has_tag 'a[href=?]', wiki_path(@section), /home/ unless @wikipage.home?
          has_tag 'a[href=?]', edit_wikipage_path(@section, @wikipage.permalink), /edit/

          # displays the wikipage's updated_at date as a microformat
          has_tag 'abbr[class=datetime][title=?]', @wikipage.updated_at.utc.xmlschema

          has_tag 'ul[class=categories]' unless @wikipage.categories.empty?
          has_tag 'ul[class=tags]'       unless @wikipage.tags.empty?

          # FIXME
          # wikifies the wikipage body
          # renders the comments/list partial
          # with a wikipage that accepts comments
          #   renders the comments/form partial
          # with a wikipage that does not accept comments
          #   does not render the comments/form partial
        end
      end

      with "a version param given" do
        before { @version = '1' }
        it_renders :template, :show
        it_reverts :wikipage, :to => 1
      end
    end

    # with :a_wikipage_accepting_comments do
    # end
    #
    # with :a_wikipage_not_accepting_comments do
    # end
  end

  describe "GET to :diff" do
    action { get :diff, :section_id => @section, :id => @wikipage.permalink, :diff_version => 1}
    before { @wikipage.update_attributes(:body => "#{@wikipage.body} was changed") }

    it_assigns :site, :section, :wikipage
    it_renders :template, :diff
  end

  describe "GET to :new" do
    action { get :new, :section_id => @section }
    it_guards_permissions :create, :wikipage

    with :access_granted do
      it_assigns :site, :section, :wikipage => :not_nil
      it_renders :template, :new do
        has_form_posting_to wikipages_path(@section) do
          shows :form
        end
      end
    end
  end

  describe "POST to :create" do
    action { post :create, (@params || {}).merge(:section_id => @section) }

    it_guards_permissions :create, :wikipage do
      it_assigns :wikipage => :not_nil

      with :valid_wikipage_params do
        it_saves :wikipage
        it_redirects_to { wikipage_url(assigns(:wikipage)) }
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :wikipage_created
      end

      with :invalid_wikipage_params do
        it_does_not_save :wikipage
        it_renders :template, :new
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
  end

  describe "GET to :edit" do
    action { get :edit, :section_id => @section, :id => @wikipage.permalink }

    it_guards_permissions :update, :wikipage do
      it_assigns :wikipage
      it_renders :template, :edit do
        has_form_putting_to @controller.send(:wikipage_path_with_home, @section, @wikipage.permalink) do
          shows :form
        end
      end
    end
  end

  describe "PUT to :update" do
    action do
      Wikipage.with_observers :wikipage_sweeper do
        put :update, (@params || {}).merge(:section_id => @section, :id => @wikipage.permalink)
      end
    end

    it_guards_permissions :update, :wikipage

    # FIXME - test with optimistic locking failing, too
    with :wikipage_optimistic_locking_passes do
      with "no version param given" do
        it_guards_permissions :update, :wikipage

        with :access_granted do
          with :valid_wikipage_params do
            it_updates :wikipage
            it_redirects_to { wikipage_url(@wikipage) }
            it_assigns_flash_cookie :notice => :not_nil
            it_triggers_event :wikipage_updated
            it_sweeps_page_cache :by_reference => :wikipage
          end

          with :invalid_wikipage_params do
            it_does_not_update :wikipage
            it_renders :template, :edit
            it_assigns_flash_cookie :error => :not_nil
            it_does_not_trigger_any_event
            it_does_not_sweep_page_cache
          end
        end
      end

      with "a version param given" do
        before { @params = { :wikipage => { :version => '1' } } }
        it_guards_permissions :update, :wikipage

        with :access_granted do
          with 'the wikipage has the requested revision (succeeds)' do
            it_rollsback :wikipage, :to => 1
            it_triggers_event :wikipage_rolledback
            it_assigns_flash_cookie :notice => :not_nil
            it_redirects_to { wikipage_url(@wikipage) }
            it_sweeps_page_cache :by_reference => :wikipage
          end

          with "the wikipage does not have the requested revision (fails)" do
            before { @params = { :wikipage => { :version => '10' } } }

            it_does_not_rollback :wikipage
            it_does_not_trigger_any_event
            it_assigns_flash_cookie :error => :not_nil
            it_redirects_to { wikipage_url(@wikipage, :version => @wikipage.version) }
            it_does_not_sweep_page_cache
          end
        end
      end
    end
  end

  describe "DELETE to :destroy" do
    action do
      Wikipage.with_observers :wikipage_sweeper do
        delete :destroy, :section_id => @section, :id => @wikipage.permalink
      end
    end
    it_guards_permissions :destroy, :wikipage

    with :access_granted do
      it_redirects_to { wiki_url(@section) }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :wikipage_deleted
      it_sweeps_page_cache :by_reference => :wikipage
    end
  end

  describe "GET to :comments" do
    action { get :comments, @params.merge(:section_id => @section) }

    with [:wiki_comment_feed_path, :wikipage_comment_feed_path] do
      it_assigns :section, :comments
      it_renders :template, 'comments/comments', :format => :atom
    end
  end
end