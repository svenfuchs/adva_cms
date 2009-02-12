require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  module UrlHistoryTests
    class SectionTest < ActionController::IntegrationTest
      def setup
        super
        @section = Section.find_by_title 'a section'
        @another_section = Section.find_by_title 'another section'
        @site = @section.site
        use_site! @site
      end
      
      unless ApplicationController.tracks_url_history?
        test "without url_history: Admin views section, edits the permalink and gets 404" do
          visit '/another-section'
          login_as_admin
          revise_the_section_permalink
          visit '/another-section'
          assert_status 404
        end
      end

      if ApplicationController.tracks_url_history?
        test "with url_history: Admin views section, edits the permalink and gets redirected" do
          visit '/'

          visit 'another-section'
          assert_status 200
          request.url.should =~ %r(/another-section)
          UrlHistory::Entry.recent_by_url(request.url).should_not be_nil

          login_as_admin
          revise_the_section_permalink
          visit 'another-section'
          assert_status 200
          request.url.should =~ %r(/another-section-updated-permalink)
        end
      end
    
      def revise_the_section_permalink
        visit "/admin/sites/#{@site.id}/sections/#{@another_section.id}/edit"
        fill_in 'section[permalink]', :with => 'another-section-updated-permalink'
        click_button 'Save'
        request.url.should =~ %r(/admin/sites/\d+/sections)
      end
    end
  end
end