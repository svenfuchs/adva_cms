Test::Unit::Assertions.module_eval do
  include ActionController::Assertions::SelectorAssertions

  def assert_html(html, *args, &block)
    assert_select(HTML::Document.new(html).root, *args, &block)
  end

  # test/unit insists that we use assert_block ... but why? 
  def assert_with_lambda(boolean = nil, message = nil)
    boolean = yield if block_given?
    assert_without_lambda(boolean, message)
  end
  
  alias :assert_without_lambda :assert
  alias :assert :assert_with_lambda
end


# have test/unit report errors asap
# thanks to Lifo http://gist.github.com/50645
require 'test/unit/ui/console/testrunner'
class Test::Unit::UI::Console::TestRunner
  def add_fault(fault)
    hax_output(fault)
    @faults << fault
    output_single(fault.single_character_display, 1)
    @already_outputted = true
  end

  def hax_output(fault)
    @io.puts("\n")
    output_single(fault.short_display, 1) # fault.long_display for the full trace
    @io.puts("\n")
  end
end