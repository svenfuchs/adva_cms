class AdvaBestAccount < ActiveRecord::Base

  attr_accessor :gtc

  # TODO
  # this should be in an AdvaBestAccountType model and should be stored in the database
  SUBSCRIPTION_FEE = 15

  acts_as_role_context

  has_many :superuser_roles, :class_name => 'Role', :foreign_key => 'ancestor_context_id', :conditions => {:name => 'superuser'}
  has_many :superusers, :through => :superuser_roles, :source => :user

  has_many :sites
  #has_many :users

  # TODO
  # why do we need a host for an account? isn't a host attribute for a site sufficient?
  # and if a host attribute is neccessary, should whitespace be remove(should it be camelcase?)
  # should the name of the account be unique? (I don't think so --Josh)
  validates_presence_of :name, :account_plan, :company_name, :address, :zip_code, :city
  validates_inclusion_of :account_plan, :in => ['free','premium']
  validates_acceptance_of :gtc, :accept

  def self.clear_cache_for_expired_free_accounts
    expired_free_accounts = self.all.select {|a| a.account_plan == 'free' && a.created_at < 30.days.ago }
    expired_free_accounts.each do |account|
      account.sites.each do |site|
        cache_dir = self.page_cache_directory_for_site(site)
        Dir["#{cache_dir}*"].each do |path|
          Pathname.new(path).rmtree if File.exists?(path)
        end
      end
    end
  end

  # *** WARNING ***: Do not change this without adjusting the method 'page_cache_directory' in config/initializers/_base_controller.rb
  def self.page_cache_directory_for_site(site)
    environment_specific_path = if Rails.env == 'test'
      'tmp'
    else
      'public'
    end
    "#{Rails.root}/#{environment_specific_path}/cache/#{site.host}"
  end

  def owners
    [self]
  end

  def privileged_account_members
    condition = [
      %{
        roles.ancestor_context_type = ? AND
        roles.ancestor_context_id = ?
      }, self.class.name, id]
    User.find :all, :joins => :roles, :conditions => condition
  end

  def remit!; update_attribute(:account_plan, 'premium'); update_attribute(:paid, true) end
  def default!
    reload  # FIX: strangely, this is necessary, at least with the sqlite3 adapter
    update_attribute(:paid, false)
  end

  def free?; account_plan == 'free' end

  def active?
    # TODO: free trial duration should be configurable somewhere
    paid? || ( free? && created_at > 30.days.ago )
  end
end
