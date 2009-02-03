class Test::Unit::TestCase
  def expectation
    RR.reset
    yield
    RR.verify
  end
end