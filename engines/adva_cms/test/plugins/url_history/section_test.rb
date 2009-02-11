require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )
require File.expand_path(File.dirname(__FILE__) + '/test_helper' )

Section.class_eval do
  def update_url_history_params(params)
    if params.has_key?(:year)
      params.merge self.full_permalink
    elsif params.has_key?(:permalink)
      params.merge :permalink => self.permalink
    else
      params
    end
  end
end

module IntegrationTests
  module UrlHistory
    class SectionTest < ActionController::IntegrationTest
      include UrlHistoryTestHelper
    
      def setup
        super
        @section = Section.find_by_title 'a section'
        @another_section = Section.find_by_title 'another section'
        @site = @section.site
        use_site! @site
      end

      test "without url_history: Admin views section, edits the permalink and gets 404" do
        uninstall_url_history!
        visit '/another-section'
        login_as_admin
        revise_the_section_permalink
        visit '/another-section'
        assert_status 404
      end

      test "with url_history: Admin views section, edits the permalink and gets redirected" do
        install_url_history!
        visit 'another-section'
        login_as_admin
        revise_the_section_permalink
        visit 'another-section'
        assert_status 200
        request.url.should =~ %r(/another-section-updated-permalink)
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