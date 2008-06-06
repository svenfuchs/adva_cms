class RolesController < BaseController
  before_filter :set_user, :set_object, :set_roles
  caches_page :index
  layout false
  
  protected
  
    def set_user
      @user = User.find params[:user_id]
    end
  
    def set_object
      @object = params[:object_type].classify.constantize.find params[:object_id] if params[:object_type]
    end
  
    def set_roles
      @roles = (@object || @site).relevant_roles(current_user).map &:to_css_class
    end
end