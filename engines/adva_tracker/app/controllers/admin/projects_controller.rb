class Admin::ProjectsController < Admin::BaseController
  guards_permissions :project 
  
  def new
    @project = @section.projects.build
  end
  
  def show
    @project = Project.find(params[:id], :include => :tickets)
    @tickets = @project.tickets
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def create
    @project = @section.projects.build(params[:project])

    if @project.save
      flash[:notice] = t(:"adva.tracker.flash.project_successfully_created")
      redirect_to admin_project_path(@site, @section, @project)
    else
      flash.now[:error] = t(:"adva.tracker.flash.project_creation_failed")
      render :action => "new"
    end
  end
  
  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:notice] = t(:"adva.tracker.flash.project_successfully_updated")
      redirect_to admin_project_path(@site, @section, @project)
    else
      flash.now[:error] = t(:"adva.tracker.flash.project_update_failed")
      render :action => "edit"
    end
  end
  
  def destroy
    @project = Project.find(params[:id])

    @project.destroy
    flash[:notice] = t(:"adva.tracker.flash.project_successfully_deleted")
    redirect_to admin_trackers_path(@site, @section)
  end
end
