def assert_page_cached
  # TODO: implement this!
  # path = ActionController::Base.send(:page_cache_path, '/')
  # get '/'
  # cached_page = CachedPage.find(:first)
  # assert Pathname.new(path).exist?
  assert true
end

def assert_not_page_cached
  # TODO: implement this!
  assert true
end

def assert_events_triggered(*types)
  actual = types.select{|type| Event::TestLog.was_triggered?(type) }
  assert_equal actual.size, types.size, "expected events #{types.inspect} to be triggered but only found #{actual.inspect}"
end

# Testing cookie based flash message what is used at Adva.
#
# Example usage:
#   assert_flash 'It was successfully updated!'
#
def assert_flash(message)
  regexp = Regexp.new(message.gsub(' ', '\\\+'))
  assert cookies['flash'] =~ regexp,
    "Flash message does NOT MATCH:\n  We should have message: #{message}\n" +
    "  BUT we got cookie: #{cookies['flash']}\n  what doesn't match to our message regexp: #{regexp}"
end

# Testing content with regexp
#
# Example usage:
#   assert_content 'looking for my content'
#
def assert_content(content)
  assert response.body =~ Regexp.new(content),
    "\nDidn't find content with regexp: /#{content}/\n" +
    "FROM:\n#{response.body}"
end
