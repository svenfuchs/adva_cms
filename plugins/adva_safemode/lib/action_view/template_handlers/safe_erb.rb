require 'safemode'
require 'erb'

module ActionView
  module TemplateHandlers
    class SafeErb < TemplateHandler
      include Compilable

      class << self
        def valid_assigns(assigns)
          assigns.reject { |key, value| skip_assigns.include?(key) }
        end

        def delegate_methods
          dm = [ :render, :params, :flash, :h, :html_escape, :request ]

          dm += [ :atom_feed, :auto_discovery_link_tag, :auto_link,
            :b64encode, :button_to, :button_to_function, :cdata_section,
            :check_box, :check_box_tag, :collection_select, :concat,
            :content_for, :content_tag, :content_tag_for, :current_cycle,
            :current_page?, :cycle, :date_select, :datetime_select,
            :decode64, :decode_b, :distance_of_time_in_words,
            :distance_of_time_in_words_to_now, :div_for, :dom_class,
            :dom_id, :encode64, :error_message_on, :error_messages_for,
            :escape_javascript, :escape_once, :excerpt, :field_set,
            :field_set_tag, :fields_for, :file_field, :file_field_tag,
            :form, :form_for, :form_tag, :grouped_collection_select,
            :grouped_options_for_select, :hidden_field, :hidden_field_tag,
            :highlight, :image_path, :image_submit_tag, :image_tag, :input,
            :javascript_cdata_section, :javascript_include_tag,
            :javascript_path, :javascript_tag, :l, :label, :label_tag,
            :link_to, :link_to_if, :link_to_unless, :link_to_unless_current,
            :localize, :mail_to, :markdown, :number_to_currency,
            :number_to_human_size, :number_to_percentage, :number_to_phone,
            :number_with_delimiter, :number_with_precision,
            :option_groups_from_collection_for_select, :options_for_select,
            :options_from_collection_for_select, :password_field,
            :password_field_tag, :path_to_image, :path_to_javascript,
            :path_to_stylesheet, :pluralize, :radio_button,
            :radio_button_tag, :reset_cycle, :sanitize, :sanitize_css,
            :select, :select_date, :select_datetime, :select_day,
            :select_hour, :select_minute, :select_month, :select_second,
            :select_tag, :select_time, :select_year, :simple_format,
            :strip_links, :strip_tags, :stylesheet_link_tag,
            :stylesheet_path, :submit_tag, :t, :tag, :text_area,
            :text_area_tag, :text_field, :text_field_tag, :textilize,
            :theme_image_path, :theme_image_tag,
            :theme_javascript_include_tag, :theme_javascript_path,
            :theme_path_to_image, :theme_path_to_javascript,
            :theme_path_to_stylesheet, :theme_stylesheet_link_tag,
            :theme_stylesheet_path, :time_ago_in_words, :time_select,
            :time_zone_options_for_select, :time_zone_select, :translate,
            :truncate, :url_for, :word_wrap ]

          dm += ActionController::Routing::Routes.named_routes.helpers
          dm.flatten.map(&:to_sym).uniq
        end

        def skip_assigns
          [ "@_cookies", "@_current_render", "@_first_render", "@_flash",
            "@_headers", "@_params", "@_request", "@_response", "@_session",
            "@assigns", "@assigns_added", "@before_filter_chain_aborted",
            "@controller", "@helpers", "@ignore_missing_templates", "@logger",
            "@real_format", "@request_origin", "@template", "@template_class",
            "@template_format", "@url", "@variables_added", "@view_paths" ]
        end
      end

      def self.line_offset
        0
      end

      def compile(template)
        src = template.source
        filename = template.filename
        erb_trim_mode = ActionView::TemplateHandlers::ERB.erb_trim_mode

        erb_code = ::ERB.new("<% __in_erb_template=true %>#{src}", nil, erb_trim_mode, '@output_buffer').src
        # Ruby 1.9 prepends an encoding to the source. However this is
        # useless because you can only set an encoding on the first line
        RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src

        # code.gsub!('\\','\\\\\\') # backslashes would disappear in compile_template/modul_eval, so we escape them
        Safemode::Boxes[filename] = Safemode::Box.new(erb_code, filename, 0)

        boxed_erb = <<-CODE
          handler = ActionView::TemplateHandlers::SafeErb
          assigns = {}
          handler.valid_assigns(instance_variables).each do |var|
            assigns[var[1,var.length]] = instance_variable_get(var)
          end
          methods = handler.delegate_methods + self.controller.master_helper_module.instance_methods

          box = Safemode::Boxes[#{filename.inspect}]
          box.eval(self, methods, assigns, local_assigns, &lambda{ |*args| yield(*args) })
        CODE
        # puts erb_code
        # puts @@safemode_boxes[filename].instance_variable_get('@code')
        boxed_erb
      end
    end
  end
end
