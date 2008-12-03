class Admin::NewsletterSubscriptionsController < Admin::BaseController
  
  def index
  end
  
  def new
    @subscription = Subscription.new
  end
end
