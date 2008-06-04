# PermalinkFu doesn't work with STI by default. Here's a fix for that.

PermalinkFu::ClassMethods.module_eval do      
  alias :has_permalink_without_fix :has_permalink
  def has_permalink(*args)
    has_permalink_without_fix(*args)
    instance_eval do
      class << self
        alias :inherited_without_permalink_fu :inherited
        def inherited(klass)
          [:permalink_attributes, :permalink_field, :permalink_options].each do |attr|
            klass.instance_variable_set :"@#{attr}", self.send(attr)
          end
          inherited_without_permalink_fu(klass)
        end
      end
    end
  end   
end

# allow an option :separator for joining several permalink attributes
# also, ignore empty attribute values (i.e. avoid results like '---something',
# instead return 'something')

PermalinkFu.module_eval do
  class << self
    alias :escape_with_empty_result :escape unless method_defined? :escape_with_empty_result
    def escape(*args)
      result = escape_with_empty_result(*args)
      result.empty? ? nil : result
    end
  end
  
  def create_permalink_for(attr_names)
    attr_names.collect do |attr_name| 
      PermalinkFu.escape(send(attr_name).to_s)
    end.compact.join(self.class.permalink_options[:separator] || '-')
  end
end