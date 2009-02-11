module UrlHistoryTestHelper
  def install_url_history!
    if ApplicationController.tracks_url_history?
      handlers = [["ActiveRecord::RecordNotFound", :url_history_record_not_found],
                  ["ActionController::RoutingError", :url_history_record_not_found]]
      ApplicationController.rescue_handlers = handlers
    else
      ApplicationController.tracks_url_history
    end
  end
  
  def uninstall_url_history!
    [ActionController::Base, ApplicationController, BaseController, SectionsController].each do |klass|
      klass.rescue_handlers.delete_if do |klass_name, handler|
        handler == :url_history_record_not_found
      end if klass.rescue_handlers.is_a?(Array)
    end
  end
end