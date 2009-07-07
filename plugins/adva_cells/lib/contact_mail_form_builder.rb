class ContactMailFormBuilder
  def add_fields(fields)
    fields.each do |field|
      add_field(field)
    end
  end

  def add_field(field)
    fields << case field[:type]
      when 'text_field'   then Tags::TextField.new(field)
      when 'text_area'    then Tags::TextArea.new(field)
      when 'radio_button' then Tags::RadioButton.new(field)
      when 'check_box'    then Tags::CheckBox.new(field)
      when 'select'       then Tags::Select.new(field)
      else ''
    end
  end

  def fields
    @fields ||= []
  end

  def render_fields
    html = ""
    fields.collect do |field|
      html += "<p>\n" + field.render + "</p>\n" if field.valid?
    end
    html
  end
end

module Tags
  class Base
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::TagHelper
    
    attr_accessor :name, :label, :value, :options
    
    def initialize(options = {})
      @name    = options[:name]
      @value   = options[:value]
      @label   = options[:label]
      @options = options[:options] || {}
    end
    
    def valid?
      !!name
    end
    
    def label_for
      field = label ? label : name.capitalize
      "\t<label for='contact_mail_#{dehumanize(field)}'>#{field}</label>\n"
    end
    
    def dehumanize(string)
      string.gsub(/([^A-Za-z0-9_])/, "_").gsub(/([_.][_.]+)/, "_").gsub(/(^[_.]|[_.]$)/, "").downcase
    end
    
    def dehumanized_name
      :"contact_mail[#{dehumanize(name)}]"
    end
    
    def type
      self.class.to_s.sub(/Tags::/, '')
    end
    
    def render
      ""
    end
  end
  
  class CheckableBase < Base
    attr_accessor :checked
    
    def initialize(options = {})
      super
      @checked = options[:checked]
    end
  end
  
  class TextField < Base
    def render
      label_for + "\t" + text_field_tag(dehumanized_name, value, options) + "\n"
    end
  end
  
  class TextArea < Base
    def text_area_options
      options.merge(:id => "contact_mail_#{name}") unless options[:id]
    end
    
    def render
      label_for + "\t" + text_area_tag(dehumanized_name, value, text_area_options) + "\n"
    end
  end
  
  class Select < Base
    attr_accessor :option_tags
    
    def initialize(options = {})
      super
      if options[:option_tags]
        @option_tags = options[:option_tags].delete('option')
      elsif options[:options] && options[:options]['option']
        @option_tags = options[:options].delete('option')
      else
        @option_tags = {}
      end
    end
    
    def formatted_option_tags
      option_tags.collect { |option| [option["label"], option["value"]] }
    end
    
    def valid?
      name && !option_tags.blank?
    end
    
    def render
      label_for + "\t" + select_tag(dehumanized_name, options_for_select(formatted_option_tags)) + "\n"
    end
  end
  
  class RadioButton < CheckableBase
    def valid?
      name && value
    end
    
    def render
      label_for + "\t" + radio_button_tag(dehumanized_name, value, checked, options) + "\n"
    end
  end
  
  class CheckBox < CheckableBase
    def render
      label_for + "\t" + check_box_tag(dehumanized_name, value, checked, options) + "\n"
    end
  end
end