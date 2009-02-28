require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'test_helper' ))

class ProjectsIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @section = Tracker.find_by_title 'tracker'
    @site = use_site! @section.site
    @section.projects.destroy_all
  end
  
  test "admin manages projects" do
    login_as_admin
    view_empty_projects
    create_new_project_with_failure
    create_new_project
    view_projects
    edit_project_with_failure
    edit_project
    destroy_project
  end
  
  def view_empty_projects
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/trackers"
    
    renders_template "admin/tracker/index"
    response.body.should have_tag("div.empty>a", "Create a new project")
  end

  def create_new_project_with_failure
    renders_template "admin/tracker/index"
    click_link "Create a new project"
    
    renders_template "admin/projects/new"
    fill_in :project_title, :with => nil
    click_button "Save"

    renders_template "admin/projects/new"
    renders_flash "Project creation failed"
    response.body.should have_tag(".field_with_error")
  end

  def create_new_project
    renders_template "admin/projects/new"
    fill_in :project_title, :with => "test project title"
    fill_in :project_desc,  :with => "test project desc"
    click_button "Save"

    renders_template "admin/projects/show"
    renders_flash "Project was successfully created"
    response.body.should have_tag("h2", "test project title")
    response.body.should have_tag("p", "test project desc")
  end
  
  def view_projects
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/trackers"

    renders_template "admin/tracker/index"
    response.body.should have_tag("td>a", "test project title")
  end
  
  def edit_project_with_failure
    click_link "Edit"

    renders_template "admin/projects/edit"
    fill_in :project_title, :with => nil
    click_button "Save"

    renders_template "admin/projects/edit"
    renders_flash "Project update failed"
  end
  
  def edit_project
    renders_template "admin/projects/edit"
    fill_in :project_title, :with => "edited project title"
    fill_in :project_desc,  :with => "edited project desc"
    click_button "Save"

    renders_template "admin/projects/show"
    renders_flash "Project was successfully updated"
  end
  
  def destroy_project
    #TODO selenium needed
  end
end
