require 'cache_references/page_caching'

ActiveRecord::Base.send :include, CacheReferences::MethodCallTracking


