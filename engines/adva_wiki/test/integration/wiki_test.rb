require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class WikiTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers
  
  def test_view_empty_wiki_with_default_permissions
    factory_scenario :site_with_a_wiki
    
    # wiki does not have any wikipages
    assert @section.wikipages.empty?
    
    # go to wiki show page
    get "/wiki"
    
    # user is redirected to login
    assert_redirected_to login_path(:return_to => request.url)
  end
  
  def test_view_empty_wiki_with_anonymous_permissions
    factory_scenario :site_with_a_wiki
    
    # wiki with anonymous permissions for creating a wikipage
    @section.update_attributes! :permissions => { :'create wikipage' => 'anonymous' }
    
    # wiki does not have any wikipages
    assert @section.wikipages.empty?
    
    # go to wiki show page
    get '/wiki'
    
    # the page renders the wiki new form
    assert_template 'wiki/new'
    
    # the page has wikipage form ...
    # ... with a title field ...
    assert_select "label[for='wikipage_title']", true
    assert_select "input[id='wikipage_title']", true
    
    # ... and a permalink field ...
    assert_select "label[for='wikipage_permalink']", true
    assert_select "input[id='wikipage_permalink']", true
    
    # ... and a body field ...
    assert_select "label[for='wikipage_body']", true
    assert_select "textarea[id='wikipage_body']", true
    
    # ... and a tag list field ...
    assert_select "label[for='wikipage_tag_list']", true
    assert_select "input[id='wikipage_tag_list']", true
    assert_select "span.hint", true
    
    # check that the page is not cached
    assert_not_page_cached
  end
  
  def test_view_wiki_home_page_and_wikipage_show_action
    factory_scenario :site_with_a_wiki, :home_wikipage_with_revision
    
    # wiki has at least one wikipage
    assert !@section.wikipages.empty?, "Wiki should have at least one wikipage"
    
    # go to wiki index page
    get wikipages_path(@section)
    
    # the page renders the wiki index page
    assert_template 'wiki/index', "Wiki should have a template for index view"
    
    # wiki index page should have list of wikipages ...
    assert_select "table#wikipages.list", true, "The page should contain a list of wikipages" do
      assert_select "tbody#wikipages-body", true do
        assert_select "tr#wikipage_#{@wikipage.id}", true do
          assert_select "a[href$='#{@wikipage.permalink}']", true
          assert_select "abbr.datetime", true
        end
      end
    end
    
    assert_select "a[href$='pages/new']", true, "The page should contain a link to new wikipage action."
    
    # check that the index page is cached
    assert_page_cached
  end
  
  def test_view_wikis_wikipage
    factory_scenario :site_with_a_wiki, :home_wikipage_with_revision
    
    # go to wikipage show page
    get "/pages/wiki-home"
    
    # the page renders the wiki index page
    assert_template 'wiki/show', "Wiki should have a template for show view"
    
    # authorized link should be visible only for following people:
    user            = "user-#{@wikipage.author.id}"
    site_admin      = "site-#{@site.id}-admin"
    wiki_moderator  = "section-#{@section.id}-moderator"
    wikipage_author = "content-#{@wikipage.id}-author"
    wikipage_owner  = "content-#{@wikipage.id}-owner"
    visible_for = "user #{user} #{wikipage_author} #{wiki_moderator} #{site_admin} #{wikipage_owner} superuser"
  
    # the page should show the wikipage ...
    assert_select "div#wikipage_#{@wikipage.id}", true do
      assert_select "div.meta", true do
        assert_select "a[href$='pages']", true
        assert_select "h4", /revision: #{@wikipage.version}/
        assert_select "p", /by: John Doe/
      end
    
      assert_select "div.content" do
        assert_select "a[href$='pages/#{@wikipage.permalink}']", true
        assert_select "p", /this is a wiki home page/
        assert_select "ul.links", true do
          assert_select "a[href='/']", true
          assert_select "li[class~='visible-for #{visible_for}']", true, "The page should contain authorized span for #{visible_for}." do
            assert_select "a[href$='edit']", true
          end
          assert_select "a[href$='rev/#{@wikipage.version - 1}']", true
        end
      end
    end
    
    # check that the index page is cached
    assert_page_cached
  end
  
  def test_viewing_wikipages_revision
    factory_scenario :site_with_a_wiki, :home_wikipage_with_revision
    
    # create a new version
    @wikipage.update_attributes! :body => 'Updated wikipage body.'
    
    # go to wikipage show page
    get "/pages/wiki-home"
    
    # authorized link should be visible only for following people:
    user            = "user-#{@wikipage.author.id}"
    site_admin      = "site-#{@site.id}-admin"
    wiki_moderator  = "section-#{@section.id}-moderator"
    wikipage_author = "content-#{@wikipage.id}-author"
    wikipage_owner  = "content-#{@wikipage.id}-owner"
    visible_for     = "user #{user} #{wikipage_author} #{wiki_moderator} #{site_admin} #{wikipage_owner} superuser"
    
    assert_select "div.content" do
      # the page should display updated wikipage body
      assert_select "p", /Updated wikipage body./, "The content of the wikipage should contain the body of the updated wikipage."
    end
    
    # The page should have a link to go to previous version ...
    assert_select "a[href$='rev/#{@wikipage.version - 1}']", true, "The page should contain the previous revision link."
    
    # go back one revision
    get wikipage_rev_path(:section_id => @section.id, :id => @wikipage.permalink, :version => (@wikipage.version - 1))
    
    assert_select "div.content" do
      # the page should display updated wikipage body
      assert_select "p", /this is a wiki home page/, "The content of the wikipage should contain the previous body of the wikipage."
    end
    
    # The page should have a link return to current version
    assert_select "a[href$='#{@wikipage.permalink}']", true, "The page should contain the link for returning to present version"
    
    # The page should have an authorized links ...
    assert_select "li[class~='visible-for #{visible_for}']", true, "The page should contain authorized span for #{visible_for}." do 
      # ... for rollback ...
      assert_select "a[href$='#{@wikipage.permalink}?version=#{@wikipage.version - 1}']", true, "The page should contain the link to rollback."
    end
    
    # check that the index page is cached
    assert_page_cached
  end
end