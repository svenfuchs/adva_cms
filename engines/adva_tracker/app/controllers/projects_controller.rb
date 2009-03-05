class ProjectsController < BaseController
  authenticates_anonymous_user
  guards_permissions :project 
  helper :tracker

  def index
    @projects = @section.projects
  end

  def show
    @project = Project.find(params[:id], :include => :tickets)
    @tickets = @project.tickets
  end
end
