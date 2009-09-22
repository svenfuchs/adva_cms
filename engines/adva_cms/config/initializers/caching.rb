require 'rack/cache/tags/adapter/action_controller'
require 'rack/cache/tags/adapter/cache_sweeper'

module PurgeByRecord
  def purge_cache_by(record)
    case record
    when Site
      # FIXME caching - google_analytics_tracking_code, meta_* (from plugins)
      purge_cache_by_tag(dom_id(record)) if changed?(record, %w(title subtitle comment_filter tag_counts))
    when Section
      # FIXME caching - options are always changed (check :template and :layout keys)
      # FIXME caching - watch options
      purge_cache_by_tag(dom_id(record)) if changed?(record, %w(title permalink options tag_counts))
    else
      purge_cache_by_tag(dom_id(record))
    end
    
    # FIXME caching
    #
    # ForumController
    # cache_tags :show, :comments, :track => [
    #   '@topics', '@boards', '@board', '@topic',
    #   {'@section' => :topics_count}, {'@section' => :posts_count},
    #   {'@boards' => :topics_count}, {'@boards' => :posts_count},
    #   {'@board' => :topics_count}, {'@board' => :posts_count},
    #   {'@topics' => :posts_count }
    # ]
  end
  
  def changed?(record, attributes)
    !(record.changed & attributes).empty?
  end
end

ActionController::Base.class_eval do
  extend Rack::Cache::Tags::Adapter::ActionController::ActMacro
  include PurgeByRecord
end

ActionController::Caching::Sweeper.class_eval do
  include Rack::Cache::Tags::Adapter::CacheSweeper
  include PurgeByRecord
end

ActiveRecord::Base.send(:include, MethodCallTracking)

ActionController::Dispatcher.middleware.instance_eval do
  use Rack::Cache, :client_ttl  => 0,
                   :verbose     => true, 
                   :metastore   => 'heap:/', # 'file:./../tmp/cache/rack/meta',
                   :entitystore => 'heap:/', # 'file:./../tmp/cache/rack/entities',
                   :tagstore    => 'heap:/'  # 'file:./../tmp/cache/rack/tags'

  use Rack::Cache::Purge
  use Rack::Cache::Tags
end