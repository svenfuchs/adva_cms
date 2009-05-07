class ContactMailsController < BaseController
  def new
    @contact_mail = @site.contact_mails.build
  end
  
  def create
    @contact_mail = @site.contact_mails.build(params[:contact_mail])
    
    if @contact_mail.save
      flash[:notice] = t(:'adva.contact_mails.flash.create.success')
      redirect_to params[:return_to] || '/'
    else
      flash[:error] = t(:'adva.contact_mails.flash.create.failure')
      render :action => :new
    end
  end
end