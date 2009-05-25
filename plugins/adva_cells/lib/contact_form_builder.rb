class ContactFormBuilder
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper

  def add_fields(fields)
    fields.each do |field|
      add_field(field)
    end
  end

  def add_field(field)
    fields << case field[:type]
      when 'text_field'   : "<p>\n" + labelized_text_field_for(field)   + "</p>\n"
      when 'text_area'    : "<p>\n" + labelized_text_area_for(field)    + "</p>\n"
      when 'radio_button' : "<p>\n" + labelized_radio_button_for(field) + "</p>\n"
      when 'check_box'    : "<p>\n" + labelized_check_box_for(field)    + "</p>\n"
      when 'select'       : "<p>\n" + labelized_select_for(field)       + "</p>\n"
      else ''
    end
  end

  def fields
    @fields ||= []
  end

  def render_fields
    fields.to_s
  end

  protected

    def labelized_text_field_for(field)
      label_for(field) + "\t" + text_field_tag(:"contact_mail[#{field[:name]}]", field[:value]) + "\n"
    end

    def labelized_text_area_for(field)
      label_for(field) + 
      "\t" + text_area_tag(:"contact_mail[#{dehumanize(field[:name])}]", field[:value], :id => "contact_mail_#{field[:name]}") + "\n"
    end

    def labelized_radio_button_for(field)
      label_for(field) + 
      "\t" + radio_button_tag(:"contact_mail[#{dehumanize(field[:name])}]", "#{field[:value]}", "#{field[:checked]}") + "\n"
    end

    def labelized_check_box_for(field)
      label_for(field) + 
      "\t" + check_box_tag(:"contact_mail[#{dehumanize(field[:name])}]", "#{field[:value]}", "#{field[:checked]}") + "\n"
    end

    def labelized_select_for(field)
      label_for(field) + 
       "\t" + select_tag(:"contact_mail[#{dehumanize(field[:name])}]", options_for_select(option_container_for(field[:options]))) + "\n"
    end

    def label_for(field)
      field = field[:label] ? field[:label] : field[:name]
      "\t<label for='contact_mail_#{dehumanize(field)}'>#{field}</label>\n"
    end

    def option_container_for(options)
      options.symbolize_keys!
      options = options.delete(:option)
      options.collect { |option| [option["label"], option["value"]] }
    end

    def dehumanize(string)
      string.gsub(/([^A-Za-z0-9_])/, "_").gsub(/([_.][_.]+)/, "_").gsub(/(^[_.]|[_.]$)/, "")
    end
end