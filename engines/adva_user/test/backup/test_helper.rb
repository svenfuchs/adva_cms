require File.expand_path(File.join(File.dirname(__FILE__), '/../../../../test/test_helper'))
plugin_fixtures = File.join(File.dirname(__FILE__), 'fixtures')
Test::Unit::TestCase.fixture_path = plugin_fixtures
$LOAD_PATH.unshift plugin_fixtures

class Test::Unit::TestCase
  def assert_message_sent(prior, message=nil)
    expected = prior + 1
    actual = ActionMailer::Base.deliveries.size
    full_message = build_message message,
      "<?> messages expected <?> message found\n", expected, actual
    assert_block(full_message) {expected == actual}
  end

  def assert_message_not_sent(prior, message=nil)
    expected = prior
    actual = ActionMailer::Base.deliveries.size
    full_message = build_message message,
      "<?> messages expected <?> message found\n", expected, actual
    assert_block(full_message) {expected == actual}
  end
end