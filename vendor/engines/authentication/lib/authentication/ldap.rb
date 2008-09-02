require 'ldap'

module Authentication

class Ldap
  attr_reader :options

  def initialize(options={})
    @options = options.reverse_merge(
      :host => '127.0.0.1',
      :port => LDAP::LDAP_PORT,
      :base => "dc=example,dc=com",
      :bind_dn => nil,
      :bind_password => nil,
      :uid_attribute => "uid",    # uid for ldap ; sAMAccountName for AD
      :uid_column => 'name'
    )
  end

  def authenticate(user, password)
    # connect to the ldap server
    conn = LDAP::Conn.new(options[:host],options[:port])
    # using proto v3
    conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
    # optionally bind as specific user
    conn.bind(options[:bind_dn],options[:bind_password]) if options[:bind_dn]
    # get the user uid from active record object
    uid = user.send options[:uid_column]
    # search the DN is the ldap using the uid on the specified attribute
    res = conn.search2(options[:base],LDAP::LDAP_SCOPE_SUBTREE,"#{options[:uid_attribute]}=#{uid}",['dn'])
    if ! res.empty?
      dn = res[0]['dn'][0]
      begin
        conn.unbind if conn.bound?
        conn.simple_bind(dn,password)
        conn.unbind
        conn = nil
        return true
      rescue LDAP::ResultError => e
        return false
      end
    end
    return false
  end

end

end

