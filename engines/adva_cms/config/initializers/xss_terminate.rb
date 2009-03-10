XssTerminate.untaint_after_find = true

module Globalize::Model::ActiveRecord::Translated::Callbacks
  def disables_xss_terminate_on_proxy_records
    globalize_proxy.filters_attributes :none => true
  end
end

