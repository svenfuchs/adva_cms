# Component caching is very fine-grained - a component is cached based on all
# of its arguments. Any more or less would result in inaccurate cache hits.
#
# === Howto
#
# First, configure fragment caching on ActionController. That cache store will be used
# for components as well.
#
# Second, decide which component actions should be cached. Some components cache better
# than others due to the nature of the arguments passed.
#
# For each component you wish to cache, add `cache :my_action` _after_ you define the
# action itself. This is necessary because your action will be wrapped with another
# method - :my_action_with_caching. This enables component actions to be cached no matter
# how they are called.
#
# === Example
#
#   class UserComponent < Components::Base
#     def show(user_id)
#       @user = User.find(user_id)
#       render
#     end
#     cache :show
#   end
#
# === Expiration
#
# I know of three general methods to expire caches:
#
# * TTL: expires a cache after some number of seconds. This works well for content that
#   is hit frequently but can stand to be a bit stale at times.
# * Versioning: caches are never actually expired, rather, they are eventually ignored
#   when all new cache requests are for a new version. This only works with cache stores
#   that have some kind of limited cache space, otherwise cache consumption will go
#   through the metaphorical roof.
# * Direct Expiration: caches are expired by name. This does not work when cache keys
#   have variable elements, or when the complete list of cache keys is not available
#   or a brute-force regular expression approach.
#
# Of those three, direct expiration is not a viable option due to the variable nature of
# component cache keys. And since both of the remaining methods are best supported by some
# variation of memcache, that is the officially recommended cache store.
#
# ==== TTL Expiration
#
# If you are using Rails' :mem_cache_store for fragments, then you can set up TTL-style
# expiration by specifying an :expires_in option, like so:
#
#   class UserComponent < Components::Base
#     def show(user_id)
#       @user = User.find(user_id)
#       render
#     end
#     cache :show, :expires_in => 15.minutes
#   end
#
# ==== Versioned Expiration
#
# Maintaining and incrementing version numbers may be implemented any number of ways. To
# use the version numbers, though, you can specify a :version option, which may either name
# a method (use a Symbol) or provide a proc. In either case, the method or proc should
# receive all of the same arguments as the action itself, and should return the version
# string.
#
#   class UserComponent < Components::Base
#     def show(user_id)
#       @user = User.find(user_id)
#       render
#     end
#     cache :show, :version => :show_cache_version
#
#     protected
#
#     def show_cache_version(user_id)
#       # you may want to find your version from a model object, from memcache, or whereever.
#       Version.for("users/show", user_id)
#     end
#   end
#
module Components::Caching
  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    # Caches the named actions by wrapping them via alias_method_chain. May only
    # be called on actions (methods) that have already been defined.
    #
    # Cache options will be passed through to the cache store's read/write methods.
    def cache(action, cache_options = nil)
      return unless ActionController::Base.cache_configured?

      class_eval <<-EOL, __FILE__, __LINE__
        cattr_accessor :#{action}_cache_options

        def #{action}_with_caching(*args)
          with_caching(:#{action}, args) do
            #{action}_without_caching(*args)
          end
        end
        alias_method_chain :#{action}, :caching
      EOL
      self.send("#{action}_cache_options=", cache_options)
    end

    def cache_store #:nodoc:
      @cache_store ||= ActionController::Base.cache_store
    end
  end

  protected

  def with_caching(action, args, &block) #:nodoc:
    key = cache_key(action, args)
    cache_options = self.send("#{action}_cache_options") || {}
    passthrough_cache_options = cache_options.reject{|k, v| reserved_cache_option_keys.include? k}
    passthrough_cache_options = nil if cache_options.empty?

    # conditional caching: the prohibited case
    if cache_options[:if] and not call(cache_options[:if], args)
      fragment = block.call
    else
      fragment = read_fragment(key, passthrough_cache_options)
      unless fragment
        fragment = block.call
        write_fragment(key, fragment, passthrough_cache_options)
      end
    end

    return fragment
  end

  def read_fragment(key, cache_options = nil) #:nodoc:
    returning self.class.cache_store.read(key, cache_options) do |content|
      logger.debug "Component Cache hit: #{key}" unless content.blank?
    end
  end

  def write_fragment(key, content, cache_options = nil) #:nodoc:
    logger.debug "Component Cache miss: #{key}"
    self.class.cache_store.write(key, content, cache_options)
  end

  # generates the cache key for the given action/args
  def cache_key(action, args = []) #:nodoc:
    key_pieces = [self.class.path, action] + args

    if v = call(versioning(action), args)
      key_pieces << "v#{v}"
    end
    key = key_pieces.collect do |arg|
      case arg
        when ActiveRecord::Base:  "#{arg.class.to_s.underscore}#{arg.id}" # note: doesn't apply to record sets
        else                      arg.to_param
      end
    end.join('/')

    ActiveSupport::Cache.expand_cache_key(key, :components)
  end

  # returns the versioning configuration for the given action, if any
  def versioning(action) #:nodoc:
    (self.send("#{action}_cache_options") || {})[:version]
  end

  private

  def call(method, args)
    case method
      when Proc: method.call(*args)
      when Symbol: send(method, *args)
    end
  end

  def reserved_cache_option_keys
    @reserved_cache_option_keys ||= [:if, :version]
  end
end
