# inspired by: http://www.oobaloo.co.uk/articles/2007/8/20/testing-rails-page-caching-in-rspec

module SpecPageCachingHelper
  ActionController::Base.public_class_method :page_cache_path

  def with_caching 
    ActionController::Base.perform_caching = true
    returning yield do
      ActionController::Base.perform_caching = false
    end
  end
  
  module ResponseHelper
    def cached?
      File.exists? ActionController::Base.page_cache_path(request.path)
    end
  end
  ActionController::TestResponse.send(:include, ResponseHelper)
end

# this monkeypatches ActionController so that the caches_page after_filter
# gets installed even when perform_caching is false at that point. the 
# controller still won't cache anything as long as perform_caching is set
# to false. but when we switch it to true in the process of testing it will
# actually kick in.
ActionController::Base.class_eval do
  class << self
    def caches_page(*actions)
      options = actions.extract_options!
      after_filter({:only => actions}.merge(options)) { |c| c.cache_page }
    end
  end
end
