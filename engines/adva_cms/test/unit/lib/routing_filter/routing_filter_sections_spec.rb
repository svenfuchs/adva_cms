=begin
require File.dirname(__FILE__) + '/../spec_helper'
#require File.dirname(__FILE__) + '/../spec_mocks'

describe "Routing Filter::Sections" do
  include SpecRoutingHelper
  #include SpecMocks

  describe "#before_recognize_path" do
    before :each do
      stub_scenario :site
      @site.sections.stub!(:paths).and_return ['section', 'section/subsection']
    end

    describe "given an incoming root path" do
      controller_name 'base'
      before :each do
        Site.should_receive(:find_by_host).with('test.host').and_return mock_site
      end

      it "should rewrite the path to /:root_section_pat when no locale is given (i.e. /)" do
        before_recognize_path(:sections, '/').should == '/sections/1'
      end

      it "should rewrite the path to /sections/:root_section_id when a locale given (i.e. /de)" do
        before_recognize_path(:sections, '/de').should == '/de/sections/1'
      end

      it "should rewrite the path to /sections/:root_section_id when a locale and a trailing slash are given (i.e. /de/)" do
        before_recognize_path(:sections, '/de/').should == '/de/sections/1'
      end
    end

    describe "given an incoming section path" do
      before :each do
        Site.should_receive(:find_by_host).with('test.host').and_return mock_section
      end

      describe "without a locale (like /section)" do
        controller_name 'base'

        it "should rewrite the path to /sections/:section_id" do
          before_recognize_path(:sections, '/section').should == '/sections/1'
        end

        it "should rewrite the path to /sections/:section_id leaving trailing stuff as is" do
          before_recognize_path(:sections, '/section/something').should == '/sections/1/something'
        end
      end

      describe "with a locale (like /en/section)" do
        controller_name 'base'

        it "should rewrite the path to /:locale/sections/:section_id" do
          before_recognize_path(:sections, '/en/section').should == '/en/sections/1'
        end

        it "should rewrite the path to /:locale/sections/:section_id leaving trailing stuff as is" do
          before_recognize_path(:sections, '/en/section/something').should == '/en/sections/1/something'
        end
      end
    end

    describe "given an incoming nested section path" do
      before :each do
        Site.should_receive(:find_by_host).with('test.host').and_return mock_section
      end

      describe "without a locale (like /section/subsection)" do
        controller_name 'base'

        it "should rewrite the path to /sections/:section_id" do
          before_recognize_path(:sections, '/section/subsection').should == '/sections/1'
        end

        it "should rewrite the path to /sections/:section_id leaving trailing stuff as is" do
          before_recognize_path(:sections, '/section/subsection/something').should == '/sections/1/something'
        end
      end

      describe "with a locale (like /en/section/subsection)" do
        controller_name 'base'

        it "should rewrite the path to /:locale/sections/:section_id" do
          before_recognize_path(:sections, '/en/section/subsection').should == '/en/sections/1'
        end

        it "should rewrite the path to /:locale/sections/:section_id leaving trailing stuff as is" do
          before_recognize_path(:sections, '/en/section/subsection/something').should == '/en/sections/1/something'
        end
      end
    end
  end

  describe "#after_url_helper" do
    before :each do
      @section = mock_section
      Section.stub!(:types).and_return ['Page']
      Section.should_receive(:find).with("1").and_return @section
    end

    [['path', ''], ['url', 'http://localhost:3000']].each do |type, host|
      describe "given a generated section #{type}" do
        [['without a locale', ''], ['with a locale', '/de']].each do |locale_text, locale|
          describe "#{locale_text} (like #{host}#{locale}/sections/1)" do
            describe "when the section is not the root section" do
              controller_name 'base'

              before :each do
                @section.should_receive(:root_section?).and_return(false)
              end

              it "should rewrite the path to #{host}#{locale}/:page_path" do
                after_url_helper(:sections, nil, "#{host}#{locale}/sections/1").should == "#{host}#{locale}/section/"
              end

              it "should rewrite the path to #{host}#{locale}/page_path leaving trailing stuff as is" do
                after_url_helper(:sections, nil, "#{host}#{locale}/sections/1/something").should == "#{host}#{locale}/section/something"
              end
            end

            describe "when the section is the root section" do
              controller_name "base"

              before :each do
                @section.should_receive(:root_section?).and_return(true)
              end

              it "should rewrite the path to #{host}#{locale}/" do
                after_url_helper(:sections, nil, "#{host}#{locale}/sections/1").should == "#{host}#{locale}/"
              end

              it "should rewrite the path to #{host}#{locale}/ leaving trailing stuff as is" do
                after_url_helper(:sections, nil, "#{host}#{locale}/sections/1/something").should == "#{host}#{locale}/something"
              end
            end
          end
        end
      end
    end
  end
end
=end
