require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

if ActionController::Base.respond_to?(:tracks_url_history)
  module IntegrationTests
    module UrlHistoryTests
      class SectionTest < ActionController::IntegrationTest
        def setup
          super
          @section = Page.find_by_title 'a page'
          @another_section = Page.find_by_title 'another page'
          @site = @section.site
          use_site! @site
        end
      
        unless ApplicationController.tracks_url_history?
          test "without url_history: Admin views page, edits the permalink and gets 404" do
            visit '/another-page'
            login_as_admin
            revise_the_page_permalink
            visit '/another-page'
            assert_status 404
          end
        end

        if ApplicationController.tracks_url_history?
          test "with url_history: Admin views page, edits the permalink and gets redirected" do
            visit '/another-page'
            assert_status 200
            request.url.should =~ %r(/another-page)
            UrlHistory::Entry.recent_by_url(request.url).should_not be_nil

            login_as_admin
            revise_the_page_permalink
            visit '/another-page'
            assert_status 200
            request.url.should =~ %r(/another-page-updated-permalink)
          end
        end
    
        def revise_the_page_permalink
          visit "/admin/sites/#{@site.id}/sections/#{@another_section.id}/edit"
          fill_in 'section[permalink]', :with => 'another-page-updated-permalink'
          click_button 'Save'
          request.url.should =~ %r(/admin/sites/\d+/sections)
        end
      end
    end
  end
end