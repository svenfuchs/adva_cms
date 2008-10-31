require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

# Story: Viewing a wikipage
#   As a visitor 
#   I want to access a wiki's pages
#   So I can read all the useful information

class WikiTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers
  
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
    
    # go to wikipage show page
    get "/pages/wiki-home"
    
    # the page renders the wikipage show page
    assert_template 'wiki/show', "Wikipage should have a template for show view"
    
    # the page should show the wikipage ...
    assert_select "div#wikipage_#{wikipage.id}", true, "The page should containt the wikipage" do
      # ... with meta info of wikipage ...
      assert_select "div.meta", true, "The page should contain meta information." do
        # ... with link to wikipages index ...
        assert_select "a[href$='pages']", true, "The page should contain a link to wikipages index."
      end
      # ... with wikipage content ...
      assert_select "div.content" do
        
      end
    end
  end
  
  # Scenario: Viewing a wikipage
  
  # Scenario: Viewing a wikipage revision
end