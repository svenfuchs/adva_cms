# this file includes embellishments to the engine models needed for the SaaS app

# add association to Site
require 'Site'

class Site < ActiveRecord::Base
  has_one :account_site_mapping
  has_one :account, :through => :account_site_mapping 
end
