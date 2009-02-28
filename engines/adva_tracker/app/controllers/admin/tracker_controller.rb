class Admin::TrackerController < Admin::BaseController
  
  def index
    @projects = @section.projects
  end
end
