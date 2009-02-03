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

# use custom translation logic
PermalinkFu.module_eval do
  class << self
    def escape_with_transliterations(str)
      transliterations.each_pair do |search_chars, replacement|
        Array(search_chars).each { |character| str.gsub!(character, replacement) }
      end
      escape_without_transliterations(str)
    end
    alias_method_chain :escape, :transliterations

    private
    def transliterations
      {
        %w(À Á Â Ã Å)  => "A",
        %w(Ä Æ)        => "Ae",
        "Ç"            => "C",
        "Ð"            => "D",
        %w(È É Ê Ë)    => "E",
        %w(Ì Í Î Ï)    => "I",
        "Ñ"            => "N",
        %w(Ò Ó Ô Õ Ø)  => "O",
        "Ö"            => "Oe",
        %w(Ù Ú Û)      => "U",
        "Ü"            => "Ue",
        "Ý"            => "Y",

        "Þ"            => "p",
        %w(à á â ã å)  => "a",
        %w(ä æ)        => "ae",
        "ç"            => "c",
        "ð"            => "d",
        %w(è é ê ë)    => "e",
        %w(ì í î ï)    => "i",
        "ñ"            => "n",
        %w(ò ó ô õ ø)  => "o",
        "ö"            => "oe",
        "ß"            => "ss",
        %w(ù ú û)      => "u",
        "ü"            => "ue",
        "ý"            => "y"
      }
    end
  end
end