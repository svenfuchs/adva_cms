class Components::View < ActionView::Base
  delegate :protect_against_forgery?, :form_authenticity_token, :to => :controller

  # TODO: rendering from a component view should be restricted to *just* rendering other components.
end