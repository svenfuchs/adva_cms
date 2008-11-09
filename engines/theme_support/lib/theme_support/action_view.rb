# module ThemeSupport
#   module ActionView
#     module TemplateFinder
#       def self.included(base)
#         base.alias_method_chain :pick_template_extension, :type_check
#       end
# 
#       def pick_template_extension_with_type_check(template_path)
#         returning pick_template_extension_without_type_check(template_path) do |ext|
#           if ext && @template.controller.respond_to?(:authorize_template_extension!)
#             @template.controller.authorize_template_extension!(template_path, ext)
#           end
#         end
#       end
#     end
#   end
# end
# 
# ActionView::TemplateFinder.send :include, ThemeSupport::ActionView::TemplateFinder
# 
# 
