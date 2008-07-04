require File.expand_path(File.dirname(__FILE__) + "/../../../helper")

Story "Publishing a blog article", %(
  As an admin
  I want to write blog articles in the admin area
  So they get published in the frontend), :steps_for => steps(:all), :type => RailsStory do
  
  Scenario "An admin writes a blog article" do
    Given "a blog with no articles"
      And "the user is logged in as admin"
    When "the user visits the blog page"
    Then "the page has an empty list of articles"
    When "the user clicks on 'Create one now &raquo;'"
    #Then "the page has a form posting to /admin/sites/1/sections/1/articles"
      And "fills in 'title' with 'the article title'"
      And "fills in 'article[body]' with 'the article body'"
      And "fills in 'article[tag_list]' with '\"foo bar\"'"
      And "the 'save as draft' checkbox is already checked"
      And "clicks the button 'Save article'"
    #When "the user POSTs to", '/admin/sites/1/sections/1/articles', :article => valid_article_attributes.update(:draft => 1)
    Then "a new article is saved"
      And "the user is redirected to /admin/sites/1/sections/1/articles/1"
  end
end
