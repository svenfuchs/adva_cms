require File.expand_path(File.dirname(__FILE__) + "/helper")

Story "Viewing a blog index page", %(
  As an anonymous visitor 
  I want to access the blog index page
  So I can see all the cool blog articles), :steps_for => steps(:default, :article), :type => RailsStory do

  Scenario "A blog index page with an article that has an exerpt" do
    Given "a published article"
    When "the user GETs $path", '/'
    Then "the page shows $text", 'the article title'
    Then "the page shows $text", 'the article excerpt'
    Then "the page does not show $text", 'the article body'
    Then "the page shows $text", "read the rest of this entry"   
  end

  Scenario "A blog index page with an article that does not have an exerpt" do
    Given "a published article that has $options", :excerpt => nil
    When "the user GETs $path", '/'
    Then "the page shows $text", "the article title"    
    Then "the page does not show $text", "the article excerpt"
    Then "the page shows $text", "the article body"
    Then "the page does not show $text", "read the rest of this entry"   
  end
  
  Scenario "A blog category index page with an article" do
    Given "a published article"
    When "the user GETs $path", '/categories/a-category'
    Then "the page shows $text", "the article title"
    Then "the page shows $text", "the article excerpt"
    Then "the page shows $text", "read the rest of this entry"   
  end
  
  Scenario "A blog tag index page with an article" do
    Given "a published article"
    When "the user GETs $path", '/tags/foo'
    Then "the page shows $text", "the article title"
    Then "the page shows $text", "the article excerpt"
    Then "the page shows $text", "read the rest of this entry"   
  end
  
  Scenario "A blog archive page with an article" do
    Given "a published article"
    When "the user GETs $path", '/2008/1'
    Then "the page shows $text", "the article title"    
    Then "the page shows $text", "the article excerpt"
    Then "the page shows $text", "read the rest of this entry"   
  end
end