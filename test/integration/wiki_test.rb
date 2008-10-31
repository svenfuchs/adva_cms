require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

# Story: Viewing a wikipage
#   As a visitor 
#   I want to access a wiki's pages
#   So I can read all the useful information

class WikiTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers
  
  def setup
    Site.delete_all
    Section.delete_all
    Content.delete_all
    Content::Version.delete_all
    User.delete_all
  end
  
  # Scenario: Viewing an empty wiki
  def test_view_empty_wiki_with_default_permissions
    site = Factory :site_with_wiki
    wiki = site.sections.first
    
    # wiki does not have any wikipages
    assert wiki.wikipages.empty?
    
    # go to wiki show page
    get "/wiki"
    
    # user is redirected to login
    assert_redirected_to '/login'
  end
  
  # Scenario: Viewing an empty wiki
  def test_view_empty_wiki_with_anonymous_permissions
    site = Factory :site_with_wiki
    wiki = site.sections.first
    
    # wiki with anonymous permissions for creating a wikipage
    wiki.update_attributes! :permissions => { :'create wikipage' => 'anonymous' }
    
    # wiki does not have any wikipages
    assert wiki.wikipages.empty?
    
    # go to wiki show page
    get '/wiki'
    
    # the page renders the wiki new form
    assert_template 'wiki/new'
    
    # the page has wikipage form ...
    # ... with a title field ...
    assert_select "label[for='wikipage_title']", true, "Wikipage form should have a label for a title form field."
    assert_select "input[id='wikipage_title']", true, "Wikipage form should have a title form field."
    
    # ... and a permalink field ...
    assert_select "label[for='wikipage_permalink']", true, "Wikipage form should have a label for a permalink form field."
    assert_select "input[id='wikipage_permalink']", true, "Wikipage form should have a permalink form field."
    
    # ... and a body field ...
    assert_select "label[for='wikipage_body']", true, "Wikipage form should have a label for a body form field."
    assert_select "textarea[id='wikipage_body']", true, "Wikipage form should have a body form field."
    
    # ... and a tag list field ...
    assert_select "label[for='wikipage_tag_list']", true, "Wikipage form should have a label for a tag list form field."
    assert_select "input[id='wikipage_tag_list']", true, "Wikipage form should have a tag list form field."
    assert_select "span.hint", true, "Wikipage form should have a hint span for tags."
    
    # check that the page is not cached
    assert_not_page_cached
  end
  
  # Scenario: Viewing the wiki home wikipage
  def test_view_wiki_home_page_and_wikipage_show_action
    site = Factory :site_with_wiki
    wiki = site.sections.first
    wiki.wikipages << Factory(:wikipage)
    wikipage = wiki.wikipages.first
    
    # wiki has at least one wikipage
    assert !wiki.wikipages.empty?, "Wiki should have at least one wikipage"
    
    # go to wiki index page
    get wikipages_path(wiki)
    
    # the page renders the wiki index page
    assert_template 'wiki/index', "Wiki should have a template for index view"
    
    # wiki index page should have list of wikipages ...
    assert_select "table#wikipages.list", true, "The page should contain a list of wikipages" do
      assert_select "tbody#wikipages-body", true do
        assert_select "tr#wikipage_#{wiki.id}", true do
          # ... with links to wikipages show actions ...
          assert_select "a[href$='#{wikipage.permalink}']", true, "The page should contain a show link for wikipage."
          # ... and display wikipage timestamp.
          assert_select "abbr.datetime", true, "The page should contain a timestamp for wikipage"
        end
      end
    end
    
    assert_select "a[href$='pages/new']", true, "The page should contain a link to new wikipage action."
    
    # check that the index page is cached
    assert_page_cached
  end
  
  # Scenario: Viewing a wikipage
  def test_view_wikis_wikipage
    site = Factory :site_with_wiki
    wiki = site.sections.first
    wiki.wikipages << Factory(:wikipage)
    wikipage = wiki.wikipages.first
    
    # go to wikipage show page
    get "/pages/wiki-home"
    
    # the page renders the wiki index page
    assert_template 'wiki/show', "Wiki should have a template for show view"
    
    # authorized link should be visible only for following people:
    user            = "user-#{wikipage.author.id}"
    site_admin      = "site-#{site.id}-admin"
    wiki_moderator  = "section-#{wiki.id}-moderator"
    wikipage_author = "content-#{wikipage.author.id}-author"
    wikipage_owner  = "content-#{wikipage.author.id}-owner"
    visible_for = "user #{user} #{wikipage_author} #{wiki_moderator} #{site_admin} #{wikipage_owner} superuser"
    
    # the page should show the wikipage ...
    assert_select "div#wikipage_#{wikipage.id}", true, "The page should containt the wikipage" do
      # ... with meta info of wikipage ...
      assert_select "div.meta", true, "The page should contain meta information." do
        # ... with link to wikipages index ...
        assert_select "a[href$='pages']", true, "The page should contain a link to wikipages index."
        # ... with revision number ...
        assert_select "h4", /revision: #{wikipage.version}/, "The meta information of the wikipage should contain a revision number."
        # ... with author name ...
        assert_select "p", /by: John Doe/, "The meta information of the wikipage should contain the name of the author"
      end
      # ... with wikipage content ...
      assert_select "div.content" do
        # ... with link to a wikipage ...
        assert_select "a[href$='pages/#{wikipage.permalink}']", true, "The page should contain a link to the wikipage."
        # ... with wikipage body ...
        assert_select "p", /this is a wiki home page/, "The content of the wikipage should contain the body of wikipage."
        # ... with link list ...
        assert_select "ul.links", true, "The page should have list of links" do
          # ... with link to the home ...
          assert_select "a[href='/']", true, "The page should contain a link to the home."
          # ... with authorized links ...
          assert_select "li[class~='visible-for #{visible_for}']", true, "The page should contain authorized span for #{visible_for}." do
            # ... with authorized edit link ...
            assert_select "a[href$='edit']", true, "The page should contain the edit link."
          end
          # ... with link to go to previous version ...
          assert_select "a[href$='rev/#{wikipage.version - 1}']", true, "The page should contain the previous revision link."
        end
      end
    end
    
    # check that the index page is cached
    assert_page_cached
  end
  
  # Scenario: Viewing a wikipage revision
  def test_viewing_wikipages_revision
    site = Factory :site_with_wiki
    wiki = site.sections.first
    wiki.wikipages << Factory(:wikipage)
    wikipage = wiki.wikipages.first
    
    # create a new version
    wikipage.update_attributes! :body => 'Updated wikipage body.'
    
    # go to wikipage show page
    get "/pages/wiki-home"
    
    assert_select "div.content" do
      # the page should display updated wikipage body
      assert_select "p", /Updated wikipage body./, "The content of the wikipage should contain the body of the updated wikipage."
    end
    
    # The page should have a link to go to previous version ...
    assert_select "a[href$='rev/#{wikipage.version - 1}']", true, "The page should contain the previous revision link."
    
    # go back one revision
    get wikipage_rev_path(:section_id => wiki.id, :id => wikipage.permalink, :version => (wikipage.version - 1))
    
    assert_select "div.content" do
      # the page should display updated wikipage body
      assert_select "p", /this is a wiki home page/, "The content of the wikipage should contain the previous body of the wikipage."
    end
    
    # The page should have a link return to current version
    assert_select "a[href$='#{wikipage.permalink}']", true, "The page should contain the link for returning to present version"
    
    # The page should have a link to go to previous version
    assert_select "a[href$='#{wikipage.permalink}?version=#{wikipage.version - 1}']", true, "The page should contain the link to rollback."
    
    # check that the index page is cached
    assert_page_cached
  end
end