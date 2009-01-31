=begin
require File.dirname(__FILE__) + '/../spec_helper'

describe "Routing Filter::Locale" do
  include SpecRoutingHelper

  describe "#before_recognize_path" do
    describe "given an incoming root path" do
      controller_name 'base'

      it "should prepend the defaule_locale to the path when no locale is given (i.e. /)" do
        before_recognize(:locale, '/').should == '/en/'
      end

      it "should not modify the path when a locale given (i.e. /de)" do
        before_recognize(:locale, '/de').should == '/de'
      end

      it "should prepend the defaule_locale to the path when no locale but a similar path segment is given (i.e. /de-something)" do
        before_recognize(:locale, '/de-something').should == '/en/de-something'
      end
    end
  end

  describe "#before_url_helper" do
    controller_name 'base'

    before :each do
      @base = mock 'base'
      # @base.instance_variable_set :@locale, 'de'
      I18n.locale = :de
    end

    it "should unshift the current locale to the args when they are a non empty array" do
      before_url_helper(:locale, @base, ['foo']).should == ['de', 'foo']
    end

    it "should not modify the args when they are an empty array" do
      before_url_helper(:locale, @base, []).should == []
    end

    it "should not modify the args when they are an array with an options hash that contains the locale" do
      before_url_helper(:locale, @base, [{'locale' => 'en', 'foo' => 'bar'}]).should == [{'locale' => 'en', 'foo' => 'bar'}]
    end

    it "should set the current locale to the args when they are an array with an options hash that does not contain the locale" do
      before_url_helper(:locale, @base, [{'foo' => 'bar'}]).should == [{'locale' => 'de', 'foo' => 'bar'}]
    end
  end

  describe "#after_url_helper" do
    controller_name 'base'

    [['url', 'http://localhost:3000'], ['path', '']].each do |type, host|
      it "should not modify the generated #{type} if no locale is present" do
        after_url_helper(:locale, nil, "#{host}/something").should == "#{host}/something"
      end

      it "should not modify the generated path/url if the locale is not the default locale" do
        after_url_helper(:locale, nil, "#{host}/de/something").should == "#{host}/de/something"
      end

      it "should remove the default locale from the generated path/url if it's followed by end-of-line" do
        after_url_helper(:locale, nil, "#{host}/en").should == "#{host}/"
      end

      it "should remove the default locale from the generated path/url if it's followed by a slash" do
        after_url_helper(:locale, nil, "#{host}/en/").should == "#{host}/"
      end
    end
  end
end
=end
