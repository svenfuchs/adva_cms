class TrackerController < BaseController
  authenticates_anonymous_user
  
  def show
    @projects = @section.projects
  end
end
