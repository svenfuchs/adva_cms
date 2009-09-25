require 'has_filter/active_record/act_macro'
ActiveRecord::Base.send :extend, HasFilter::ActiveRecord::ActMacro

require_dependency 'has_filter'

register_javascript_expansion :admin => %w( has_filter/jquery.filter )
register_stylesheet_expansion :admin => %w( has_filter/filter )
register_stylesheet_expansion :admin_alternate => %w( has_filter/alternate/filter )
