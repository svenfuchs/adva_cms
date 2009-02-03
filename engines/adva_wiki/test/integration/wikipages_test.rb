require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class WikipagesTest < ActionController::IntegrationTest
    def setup
      super
      @section = Wiki.find_by_title 'a wiki'
      @site = use_site! @section.site
      @wikipage = @section.wikipages.find_by_permalink 'another-wikipage'
      @previous_revision = @wikipage.versions[@wikipage.versions.count - 1]
    end
    
    # FIXME test with an anonymous user as well as they have some additional form fields
    
    test "An admin edits a wikipage, reviews a previous revision and rolls back to it" do
      login_as_admin
      visit_another_wikipage
      edit_another_wikipage
      review_previous_wikipage_revision
      rollback_to_previous_wikipage_revision
    end
    
    def visit_another_wikipage
      visit "/pages/another-wikipage"
      renders_template 'wiki/show'
    end
    
    def edit_another_wikipage
      click_link 'edit'
      fill_in 'wikipage[body]', :with => 'revised wikipage body'
      click_button 'save'
      renders_template 'wiki/show'
      response.body.should have_tag('.entry .content', /revised wikipage body/)
    end
    
    def review_previous_wikipage_revision
      click_link 'view previous revision'
      renders_template 'wiki/show'
      response.body.should have_tag('.entry .content', /#{Regexp.escape(@previous_revision.body)}/)
    end
    
    def rollback_to_previous_wikipage_revision
      click_link 'rollback to this revision'
      renders_template 'wiki/show'
      response.body.should have_tag('.entry .content', /#{Regexp.escape(@previous_revision.body)}/)
    end
  end
end