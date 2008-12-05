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
end
