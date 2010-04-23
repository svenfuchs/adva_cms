module ActionView
  module TemplateHandlers
    module SafemodeHandler
      def valid_assigns(assigns)
        assigns.reject { |key, value| skip_assigns.include?(key) }
      end

      def delegate_methods(methods = [])
        methods += [ :render, :params, :flash, :h, :html_escape, :request, :output_buffer, :output_buffer= ]
        methods += [ :atom_feed, :auto_discovery_link_tag, :auto_link,
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
        methods += [ :will_paginate ] #FIXME this is from a plugin, but oh-so-commonly used
        methods += [ :current_user, :calendar_for, :wikipage_path_with_home ] # this should be taken care of by helpermethods...
        methods += ActionController::Routing::Routes.named_routes.helpers
        methods.flatten.map(&:to_sym).uniq
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
  end
end
