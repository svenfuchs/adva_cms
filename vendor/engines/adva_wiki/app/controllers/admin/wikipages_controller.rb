class Admin::WikipagesController < Admin::BaseController
  layout "admin"

  before_filter :set_section
  before_filter :set_wikipage, :only => [:destroy]

  widget :menu_section,  :partial => 'widgets/admin/menu_section',
                         :only  => { :controller => ['admin/wikipages'] }

  guards_permissions :wikipage

  def index
    @wikipages = @section.wikipages.paginate :page => current_page, :per_page => params[:per_page]
  end

  # TODO add a wikipages admin area, analog to articles area

  # def destroy
  #   if @wikipage.destroy
  #     flash[:notice] = "The wikipage has been deleted."
  #     redirect_to admin_wikipages_path
  #   else
  #     flash[:error] = "The wikipage could not be deleted."
  #     render :action => 'show'
  #   end
  # end

  private

    def set_section; super; end

    def set_wikipage
      @wikipage = @section.wikipages.find params[:id]
      @wikipage.revert_to params[:version] if params[:version]
    end
end

