# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections_without_route_reloading do |inflect|
  inflect.singular 'Anonymous', 'Anonymous'
  inflect.singular 'anonymous', 'anonymous'
  inflect.irregular 'anonymous', 'anonymouses'
end
