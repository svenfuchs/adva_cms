class Admin::NewsletterSubscriptionsController < Admin::BaseController
  
  def index
    @newsletter = Newsletter.find(params[:newsletter_id])
    @subscriptions = @newsletter.subscriptions
  end
  
  def new
    @newsletter = Newsletter.find(params[:newsletter_id])
    @subscription = Subscription.new
  end
  
  def create
    @newsletter = Newsletter.find(params[:newsletter_id])
    @subscription = @newsletter.subscriptions.build(params[:subscription])
    
    if @subscription.save
      redirect_to admin_subscriptions_path(@site, @newsletter)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy
    flash[:notice] = t('adva.subscription.flash.destroy_success')
    redirect_to admin_subscriptions_path(@site, @subscription.subscribable_id)
  end
end
