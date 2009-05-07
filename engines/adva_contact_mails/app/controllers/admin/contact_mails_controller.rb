class Admin::ContactMailsController < Admin::BaseController
  
  before_filter :set_contact_mails, :only => :index
  before_filter :set_contact_mail,  :only => [:show, :destroy]
  
  def destroy
    @contact_mail.destroy
    flash[:notice] = t(:'adva.contact_mails.flash.destroy.success')
    redirect_to params[:return_to] || admin_contact_mails_path(@site)
  end
  
  protected
    def set_contact_mails
      options = { :page => current_page, :per_page => 25, :order => 'created_at DESC' }
      @contact_mails = @site.contact_mails.paginate options
    end
    
    def set_contact_mail
      @contact_mail = @site.contact_mails.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t(:'adva.contact_mails.flash.record_not_found')
      write_flash_to_cookie # FIXME make around filter or something
      redirect_to admin_contact_mails_path(@site)
    end
end