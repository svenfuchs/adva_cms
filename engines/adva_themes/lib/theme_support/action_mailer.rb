# NOT IMPLEMENTED


# # Extend the Base ActionController to support themes
# ActionMailer::Base.class_eval do
#   alias_method :__render, :render
#   alias_method :__initialize, :initialize
#
#   @current_theme = nil
#   attr_reader :current_theme
#
#   def initialize(method_name=nil, *args)
#     if args.last.is_a? Hash and (args.last.include? :theme)
#       @current_theme = args.last[:theme]
#       args.last.delete :theme
#       args.last[:current_theme] = @current_theme
#     end
#     create!(method_name, *args) if method_name
#   end
#
#   def render(opts)
#     body = opts.delete(:body)
#     body[:current_theme] = @current_theme
#     opts[:file] = "#{mailer_name}/#{opts[:file]}"
#     initialize_template_class(body).render(opts)
#   end
# end