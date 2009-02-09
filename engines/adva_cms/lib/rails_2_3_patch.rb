# Rails::Initializer.class_eval
#   def initialize_framework_views
#     if configuration.frameworks.include?(:action_view)
#       ActionMailer::Base.template_root  = configuration.view_path if configuration.frameworks.include?(:action_mailer) && ActionMailer::Base.view_paths.blank?
#       ActionController::Base.view_paths = configuration.view_path if configuration.frameworks.include?(:action_controller) && ActionController::Base.view_paths.blank?
#     end
#   end
# end
# 
# Rails::Plugin::Loader.class_eval do
#   def add_engine_view_paths
#     paths = ActionView::PathSet.new(engines.collect(&:view_path).reverse)
#     ActionMailer::Base.view_paths.concat paths
#     ActionController::Base.view_paths.concat paths
#   end
# end
# 
# ActionMailer::Base.class_eval do
#   def initialize_template_class(assigns)
#     template = ActionView::Base.new(ActionMailer::Base.view_paths, assigns, self)
#     template.template_format = default_template_format
#     template
#   end
# end