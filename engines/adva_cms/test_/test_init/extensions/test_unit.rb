Test::Unit::Assertions.module_eval do
  # test/unit insists that we use assert_block ... but why? 
  # I prefer the shorter version:
  
  def assert_with_lambda(boolean = nil, message = nil)
    boolean = yield if block_given?
    assert_without_lambda(boolean, message)
  end
  
  alias :assert_without_lambda :assert
  alias :assert :assert_with_lambda
end
