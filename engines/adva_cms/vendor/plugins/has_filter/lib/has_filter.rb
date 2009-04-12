require_dependency 'has_filter/filter'

module HasFilter
  def filter_for(klass, options = {})
    form_tag(options.delete(:url) || request.path, :method => :get, :id => 'filters', :class => 'filters') do
      klass.filter_chain.to_form_fields(self, options).join("\n") + "\n" +
      content_tag(:div, :class => 'submit') do
        link_to_function(I18n.t(:"filter.submit.value", :default => 'Apply'), '$("filters").submit()')
      end
      # submit_tag(I18n.t(:"filter.submit.value", :default => 'Apply'), :class => 'submit')
    end
  end
end