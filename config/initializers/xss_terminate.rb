XssTerminate.untaint_after_find = true
# XssTerminate.default_filter = :escape # why would we want to do this?

ActiveRecord::Base.class_eval do
  class << self
    alias :acts_as_versioned_without_filters_attributes :acts_as_versioned
    def acts_as_versioned(*args)
      acts_as_versioned_without_filters_attributes(*args)
      versioned_class.filters_attributes :none => true
    end
  end
end