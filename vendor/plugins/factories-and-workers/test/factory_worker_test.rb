require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class FactoryWorkerTest < Test::Unit::TestCase
  include FactoriesAndWorkers::Worker
  
  factory_worker :one do
    @@foo = "one!"
  end

  factory_worker :two => :one do
    @@foo += " two!"
  end

  factory_worker :three do
    @@foo += " three!"
  end

  factory_worker :count => [ :one, :two ]
  factory_worker :count => [ :three ]
  
  def test_worker
    worker :one
    assert_equal "one!", @@foo
  end

  def test_worker_with_dependencies
    worker :two
    assert_equal "one! two!", @@foo
  end

  def test_worker_with_dependencies_2
    worker :count
    assert_equal "one! two! three!", @@foo
  end

end
