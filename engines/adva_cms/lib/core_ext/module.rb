Module.class_eval do
  # A hash that maps Class names to an array of Modules to mix in when the class is instantiated.
  @@class_mixins = {} unless defined?(@@class_mixins)
  mattr_reader :class_mixins

  # Specifies that this module should be included into the given classes when they are instantiated.
  #
  #   module FooMethods
  #     include_into "Foo", "Bar"
  #   end
  #
  # You can also specify a hash to have your module's methods alias_method_chained to the target
  # class' methods.
  #
  #   module FooMethods
  #      include_into "Foo", :method => :feature
  #   end
  #
  # This will alias Foo#method to the newly included FooMethods#method_with_feature. The former
  # method Foo#method will continue to be available as Foo#method_without_feature.
  #
  def include_into(*klasses)
    klasses.flatten!
    aliases = klasses.last.is_a?(Hash) ? klasses.pop : {}
    klasses.each do |klass|
      (@@class_mixins[klass] ||= []) << [name.to_s, aliases]
      @@class_mixins[klass].uniq!
    end
  end

  # add any class mixins that have been registered for this class
  def auto_include!
    if mixins = @@class_mixins[name]
      mixins.each do |name, aliases|
        include name.constantize
        aliases.each { |args| alias_chain *args }
      end
    end
  end

  def alias_chain(target, feature)
    (class << self; self end).class_eval <<-EOC, __FILE__, __LINE__
      def method_added_with_#{target}_#{feature}(method)
        if method == :#{target} && !method_defined?(:#{target}_without_#{feature})
          alias_method_chain :#{target}, :#{feature}
        end
        method_added_without_#{target}_#{feature}(method)
      end
      alias_method_chain :method_added, :#{target}_#{feature}
    EOC
  end
end

Class.class_eval do
  # Instantiates a class and adds in any class_mixins that have been registered for it.
  def inherited_with_mixins(klass)
    returning inherited_without_mixins(klass) do |value|
      klass.auto_include!
    end
  end

  alias_method_chain :inherited, :mixins
end
