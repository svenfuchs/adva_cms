ActionController::Routing::Routes.draw do |map|
  map.contact_mails            'contact_mails',
                               :controller   => 'contact_mails',
                               :action       => 'create',
                               :conditions   => { :method => :post }
end