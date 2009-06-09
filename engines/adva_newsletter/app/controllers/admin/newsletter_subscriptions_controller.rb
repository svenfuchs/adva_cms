class Admin::NewsletterSubscriptionsController < Admin::BaseController
  guards_permissions :newsletter_subscription 
  
  def index
    @newsletter = Adva::Newsletter.find(params[:newsletter_id])
    @subscriptions = @newsletter.subscriptions
  end
  
  def new
    @newsletter = Adva::Newsletter.find(params[:newsletter_id])
    @subscription = Adva::Subscription.new
  end
  
  def create
    @newsletter = Adva::Newsletter.find(params[:newsletter_id])
    @subscription = @newsletter.subscriptions.build(params[:subscription])
    
    if @subscription.save
      redirect_to admin_adva_subscriptions_url(@site, @newsletter)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @subscription = Adva::Subscription.find(params[:id])
    @subscription.destroy
    flash[:notice] = t(:'adva.subscription.flash.destroy_success')
    redirect_to admin_adva_subscriptions_url(@site, @subscription.subscribable_id)
  end
  
  protected
  
    def set_menu
      @menu = Menus::Admin::NewsletterSubscriptions.new
    end
end
