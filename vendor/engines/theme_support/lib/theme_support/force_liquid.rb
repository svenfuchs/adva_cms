

# NOT IMPLEMENTED


# ActionController
  
# TODO abstract this to force_type(types, ...)
# 
# module ClassMethods
#   def force_liquid(value)
#     write_inheritable_attribute "force_liquid", value
#   end
# end
# 
# def force_liquid?
#   self.class.read_inheritable_attribute("force_liquid") ? true : false
# end

# ActionView

#   def pick_template_extension_with_liquid_check(template_path)
#     ext = pick_template_extension_without_liquid_check(template_path)
#     if force_liquid? and ext.to_s != 'liquid'
#       raise Theme::NoLiquidTemplateError.new("Template '#{template_path}' must be a liquid template")
#     end
#     ext
#   end
#   alias_method_chain :pick_template_extension, :liquid_check
#   
# private
# 
#   def force_liquid?
#     controller.force_liquid? unless controller.nil?
#   end
#
# module ActionView
#    private
#     def get_current_theme(local_assigns)
#       unless controller.nil?
#         if controller.respond_to?('current_theme')
#           return controller.current_theme || false
#         end
#       end
#       # Used with ActionMailers
#       if local_assigns.include? :current_theme 
#         return local_assigns.delete :current_theme
#       end
#     end
#   end
# end