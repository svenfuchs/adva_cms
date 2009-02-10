require 'radius/auth'

module Authentication

class Radius
  attr_reader :options

  def initialize(options={})
    @options = options.reverse_merge!(
      :host => '127.0.0.1',
      :bind_ip => nil,
      :timeout => 5,
      :secret => "",
      :uid_column => 'name'
    )
  end

  def authenticate(user, password)

  	begin
      auth = ::Radius::Auth.new( File.expand_path("../radius/dictionary",File.dirname(__FILE__)),options[:host],options[:bind],options[:timeout] )
      uid = user.send options[:uid_column]
      if auth.check_passwd(uid, password,options[:secret])
        return true
      else
        return false
      end
    rescue => e
      return false
    end

    return false
  end

end

end