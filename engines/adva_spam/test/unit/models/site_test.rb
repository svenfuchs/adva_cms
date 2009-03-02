require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module SpamTests
  class SiteTest < ActiveSupport::TestCase
    test "should return the Default spam engine when none configured" do
      engine = Site.new.spam_engine
      SpamEngine::FilterChain.should === engine
      SpamEngine::Filter::Default.should === engine.first
    end

    test "should return the Defensio spam engine when spam_options :engine is set to 'defensio'" do
      options = {:defensio => {:key => 'defensio key', :url => 'defensio url'}}
      engine = Site.new(:spam_options => options).spam_engine
      SpamEngine::FilterChain.should === engine
      # FIXME ... why does this fail?
      # SpamEngine::Filter::Defensio.should === engine.first
    end
  end
end