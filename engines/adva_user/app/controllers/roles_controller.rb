class RolesController < BaseController
  layout false
  helper :users, :roles
  caches_page_with_references :index
  before_filter :set_user, :set_object, :set_roles

  def index
    respond_to do |format|
      format.js
    end
  end

  protected

    def set_user
      @user = User.find params[:user_id]
    end

    def set_object
      @object = params[:object_type].classify.constantize.find params[:object_id] if params[:object_type]
    end

    def set_roles
      @roles = current_user.roles.by_context(@object || @site)
    end
end