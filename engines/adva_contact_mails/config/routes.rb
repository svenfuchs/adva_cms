ActionController::Routing::Routes.draw do |map|
  map.admin_contact_mails      'admin/sites/:site_id/contact_mails',
                                :controller   => 'admin/contact_mails',
                                :action       => 'index',
                                :conditions   => { :method => :get }
  
  map.admin_contact_mail       'admin/sites/:site_id/contact_mails/:id',
                               :controller   => 'admin/contact_mails',
                               :action       => 'show',
                               :conditions   => { :method => :get }
  
  map.admin_contact_mail       'admin/sites/:site_id/contact_mails/:id',
                               :controller   => 'admin/contact_mails',
                               :action       => 'destroy',
                               :conditions   => { :method => :delete }
                               
  map.new_contact_mail         'contact_mails/new',
                               :controller   => 'contact_mails',
                               :action       => 'new',
                               :conditions   => { :method => :get }
  
  map.contact_mails            'contact_mails',
                               :controller   => 'contact_mails',
                               :action       => 'create',
                               :conditions   => { :method => :post }
end