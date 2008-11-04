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

