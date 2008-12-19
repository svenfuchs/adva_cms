require File.dirname(__FILE__) + '/test_helper'

class CachingTest < Test::Unit::TestCase
  def setup
    ActionController::Base.stubs(:cache_configured?).returns(true)
    klass = HelloWorldComponent.dup
    klass.stubs(:path).returns("hello_world")
    klass.send(:cache, :say_it)
    @component = klass.new
  end

  def test_cache_method_chaining
    @component.expects(:with_caching).with(:say_it, ["janadumplet"]).returns("janadoomplet")
    assert_equal "janadoomplet", @component.say_it("janadumplet")
  end

  def test_cache_key_generation
    assert_equal "components/hello_world/say_it", @component.send(:cache_key, :say_it), "simplest cache key"
    assert_equal "components/hello_world/say_it/trumpapum", @component.send(:cache_key, :say_it, ["trumpapum"]), "uses arguments"
    assert_equal "components/hello_world/say_it/a/1/2/3/foo=bar", @component.send(:cache_key, :say_it, ["a", [1,2,3], {:foo => :bar}]), "handles mixed types"
    assert_equal "components/hello_world/say_it/a=1&b=2", @component.send(:cache_key, :say_it, [{:b => 2, :a => 1}]), "hash keys are ordered"
  end

  def test_conditional_caching
    @component.say_it_cache_options = {:if => proc{false}}
    @component.expects(:read_fragment).never
    assert_equal "trimpanta", @component.say_it("trimpanta")
  end

  def test_cache_hit
    @component.expects(:read_fragment).with("components/hello_world/say_it/loudly", nil).returns("LOUDLY!")
    @component.expects(:say_it_without_caching).never
    @component.say_it("loudly")
  end

  def test_cache_miss
    @component.expects(:read_fragment).returns(nil)
    @component.expects(:write_fragment).with("components/hello_world/say_it/frumpamumpa", "frumpamumpa", nil)
    assert_equal "frumpamumpa", @component.say_it("frumpamumpa")
  end

  def test_expires_in_passthrough
    @component.say_it_cache_options = {:expires_in => 15.minutes}
    @component.expects(:write_fragment).with("components/hello_world/say_it/ninnanana", "ninnanana", {:expires_in => 15.minutes})
    assert_equal "ninnanana", @component.say_it("ninnanana")
  end

  def test_versioned_keys
    @component.say_it_cache_options = {:version => :some_named_method}
    @component.expects(:some_named_method).with("rangleratta").returns(314)
    assert_equal "components/hello_world/say_it/rangleratta/v314", @component.send(:cache_key, :say_it, ["rangleratta"])
  end
end
