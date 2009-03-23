class Admin::NewsletterSubscriptionsController < Admin::BaseController
  content_for :'main_left', :newsletters_manage, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.newsletters.manage').render(self)
  end

  content_for :'main_right', :newsletters_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.newsletters.actions').render(self)
  end

  guards_permissions :newsletter_subscription 
  
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
    flash[:notice] = t(:'adva.subscription.flash.destroy_success')
    redirect_to admin_subscriptions_path(@site, @subscription.subscribable_id)
  end
end
