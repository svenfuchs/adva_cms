# additions + refactorings: 
# 
# * allowed options to be passed as symbols (e.g. :sanitize => :body)
# * added an escape_html filter that acts the same way as CGI::escapeHTML does
#   but leaves the & character unchanged (because that behaviour is not 
#   idempotent and results in & in &amp; being escaped every time the filter
#   is applied)
# * added explicit options to access the strip_tags and escape_html filters
# * added an option :none to completely turn off sanitizing for a class
#   (useful e.g. for acts_as_versioned where versions don't need to be 
#   refiltered)
# * added an alias filters_attributes for xss_terminate (because this seems
#   like a more descriptive method name and more in line with the Rails naming
#   conventions)
# * added a module level option :default_filter to allow users to select the
#   default filter
# * added a module level option :untaint_after_find and an after_find hook
#   which untaints filtered attributes after the where retrieved from the
#   database (in order to integrate nicely with SafeERB).
# * made :xss_terminate_options an superclass_delegating_reader in order to
#   fix things for cases where a model gets included before XssTerminate is
#   loaded
# * changed the filter process to now work with Arrays and Hashes (i.e. the
#   ActiveRecord serializes feature)
# * changed the filter process to directly access @attributes instead of
#   self[] (i.e. read/write_attribute) to circumvent any third-party additions
#   that hook in here
# * renamed and refactored a bit more :)

module XssTerminate
  mattr_accessor :default_filter
  @@default_filter = :strip_tags
    
  mattr_accessor :untaint_after_find
  @@untaint_after_find = false
  
  mattr_accessor :sanitize_filters
  @@sanitize_filters = [:html5lib_sanitize, :sanitize, :strip_tags, :escape]
    
  def self.included(base)
    base.extend(ClassMethods)
    # sets up default of stripping tags for all fields
    base.send(:xss_terminate)
  end

  module ClassMethods
    def xss_terminate(options = {})
      before_save :sanitize_attributes!

      superclass_delegating_reader :xss_terminate_options
      @xss_terminate_options = {}
      
      keys = [:except, *XssTerminate.sanitize_filters]
      options.assert_valid_keys :none, *keys
      
      keys.each do |key| 
        option = options[key] || []
        @xss_terminate_options[key] = option.is_a?(Array) ? option : [option]
      end
      @xss_terminate_options[:none] = options[:none]
      
      include XssTerminate::InstanceMethods
    end
    
    alias :filters_attributes :xss_terminate
  end
  
  module InstanceMethods
    def after_find
      @attributes.each do |name, value|
        unless xss_terminate_options[:except].include?(name.to_sym)
          @attributes[name].untaint
        end
      end
    end
        
    def sanitize_attributes!
      # puts "sanitize attributes #{self.inspect}"
      return if xss_terminate_options[:none]
      select_attributes_to_sanitize.each do |attribute|
        filter = select_sanitize_filter(attribute)
        sanitize_attribute! filter, @attributes[attribute]
      end 
    end
    
    def sanitize_attribute!(filter, value)
      case value
      when Array
        value.map{|v| sanitize_attribute!(filter, v) }
      when Hash
        value.each{|k, v| sanitize_attribute!(filter, v) }
        value
      when String
        # TODO is it safe to exclude frozen strings? this ran into an error
        # when with a polymorphic object_type attribute (User#save_roles)
        value.replace send(filter, value) unless value.frozen? 
      when ActiveRecord::Base, Numeric, NilClass, TrueClass, FalseClass
        # nothing to sanitize
      else
        raise "can't sanitize #{value.class.name} #{value.inspect}"
      end
    end
    
    def select_attributes_to_sanitize
      self.class.columns.select do |column| 
        [:string, :text].include?(column.type) && 
          !xss_terminate_options[:except].include?(column.name.to_sym)
      end.map(&:name)
    end
    
    def select_sanitize_filter(attribute)
      XssTerminate.sanitize_filters.detect do |filter|
        xss_terminate_options[filter].include?(attribute.to_sym)
      end || XssTerminate.default_filter 
    end
    
    def html5lib_sanitize(value)
      HTML5libSanitize.new.sanitize_html(value)
    end
    
    def sanitize(value)
      RailsSanitize.white_list_sanitizer.sanitize(value)
    end
    
    def strip_tags(value)
      RailsSanitize.full_sanitizer.sanitize(value)
    end
    
    # Can't use CGI::escapeHTML for this because it also escapes & to &amp;
    # which isn't idempotent (i.e. saving the same value multiple times would
    # cause the & in &amp; being escaped every time).
    def escape(value)
      replace = { '"' => '&quot;', '<' => '&lt;', '>' => '&gt;' }
      value.gsub(/["<>]/){|char| replace[char] }
    end
  end
end
ActiveRecord::Base.send :include, XssTerminate