require "ezcrypto.rb"
module ActiveCrypto # :nodoc:
    
    def self.append_features(base)  #:nodoc:
      super
      base.extend(ClassMethods)
    end
    
=begin rdoc

Usage is very simple. You will generally only need the two class methods listed here in your ActiveRecord class model.

== License

ActiveCrypto and EzCrypto are released under the MIT license.


== Support

To contact the author, send mail to pelleb@gmail.com

Also see my blogs at:
http://stakeventures.com and
http://neubia.com

This project was based on code used in my project StakeItOut, where you can securely share web services with your partners.
https://stakeitout.com

(C) 2005 Pelle Braendgaard

=end
    module ClassMethods
      @@session_keys={}

=begin rdoc
Turn encryption on for this record. List all encrypted attributes

  class Document < ActiveRecord::Base
		encrypt :title,:body
	end

Options are:
  <tt>key</tt> - to specify an external KeyHolder, which holds the key used for encrypting and decrypting
  <tt>base64</tt> - set to true in order to base64 encode the encrypted attributes.  defaults to false

  class Document < ActiveRecord::Base
  	belongs_to :user
  	encrypt :title,:body,:key=>:user, :base64 => true
  end
	
=end
      def encrypt(*attributes)        
      	include ActiveCrypto::Encrypted
      	before_save :encrypt_attributes
      	after_save :decrypt_attributes
        options=attributes.last.is_a?(Hash) ? attributes.pop : {}
        keyholder
        if options and options[:key]
  				module_eval <<-"end;"				 
  					def session_key
  						(send :#{options[:key]} ).send :session_key
  					end	 
  					@@external_key=true
  				end;
        end

        base64_encode = (options and options[:base64])
        module_eval <<-"end;"
          def self.ezcrypto_base64?
            #{base64_encode.to_s}
          end
        end;
        
        self.encrypted_attributes=attributes
      end   
		
=begin rdoc
Creates support in this class for holding a key. Adds the following methods:

* enter_password(password,salt="onetwothree")
* set_session_key(key)
* session_key

Use it as follows:

  class User < ActiveRecord::Base
  	has_many :documents
  	keyholder
  end

=end        
      def keyholder()
      	include ActiveCrypto::AssociationKeyHolder   
      	after_create :save_session_key       
      end

=begin rdoc
Clears the session_key array. Generally this is handled automatically as a filter in ActionController. Only use these if you need to
do something out of the ordinary.
=end
      def clear_session_keys() #:nodoc:
        @@session_keys.clear
      end 
      
=begin rdoc
Sets the session_keys array. Only use these if you need to
do something out of the ordinary, as it is handled
=end
      def session_keys=(keys) #:nodoc:
        @@session_keys=keys
      end
      
      def session_keys() #:nodoc:
        @@session_keys
      end
      
    end

=begin rdoc
This module handles all standard key management features.
=end
    module KeyHolder   

=begin rdoc
Creates a key for object based on given password and an optional salt.
=end
      def enter_password(password,salt="onetwothree")
        set_session_key(EzCrypto::Key.with_password(password, salt))
      end

=begin rdoc
Decodes the Base64 encoded key and uses it as it's session key
=end
      def set_encoded_key(enc)
        set_session_key(EzCrypto::Key.decode(enc))
      end
=begin rdoc
Sets a session key for the object. This should be a EzCrypto::Key instance.
=end
      def set_session_key(key)    
        @session_key=key
        self.decrypt_attributes if self.class.include? Encrypted
      end      

=begin rdoc
Returns the session_key
=end
      def session_key
        @session_key
      end
      
    end

    module AssociationKeyHolder   
      include ActiveCrypto::KeyHolder
      
      
      def save_session_key
        ActiveRecord::Base.session_keys[session_key_id]=@session_key if @session_key
      end
=begin rdoc
Sets a session key for the object. This should be a EzCrypto::Key instance.
=end
      def set_session_key(key)    
        if self.new_record?
          @session_key=key
        else
          ActiveRecord::Base.session_keys[session_key_id]=key
        end
        decrypt_attributes if self.class.include? Encrypted #if respond_to?(:decrypt_attributes)
        
      end      

=begin rdoc
Returns the session_key
=end
      def session_key
        if self.new_record?
          @session_key
        else
          ActiveRecord::Base.session_keys[session_key_id]
        end
      end
        
      

      def session_key_id
        "#{self.class.to_s}:#{id}"
      end      
      
    end

    module Encrypted    #:nodoc:
      def self.append_features(base)  #:nodoc:
        super
        base.extend ClassAccessors
      end
      
      module ClassAccessors
        def encrypted_attributes
          @encrypted_attributes||=[]
        end

        def encrypted_attributes=(attrs)
          @encrypted_attributes=attrs
        end
        
      end
    
      protected

      def encrypt_attributes
        if !is_encrypted?
          self.class.encrypted_attributes.each do |key|
            value=read_attribute(key)
            write_attribute(key,_encrypt(value)) if value
          end
          @is_encrypted=true
        end
        true
      end
    
      def decrypt_attributes
        if is_encrypted?
          self.class.encrypted_attributes.each do |key|
            value=read_attribute(key)
            write_attribute(key,_decrypt(value)) if value
          end
          @is_encrypted=false
        end
        true
      end
      
      def after_find
        @is_encrypted=true
        decrypt_attributes unless session_key.nil?
      end
      
      private
      def is_encrypted?
        @is_encrypted
      end
      
      def _decrypt(data)
        if session_key.nil?
          raise MissingKeyError
        else
          if data
            self.class.ezcrypto_base64? ? session_key.decrypt64(data) : session_key.decrypt(data)
          else
            nil
          end
        end
      end
    
      def _encrypt(data)
        if session_key.nil?
          raise MissingKeyError
        else 
          if data
            self.class.ezcrypto_base64? ? session_key.encrypt64(data) : session_key.encrypt(data)
          else
            nil
          end
        end
      end
               
    end
  

module ActionController # :nodoc:
=begin rdoc
This includes some basic support in the ActionController for handling session keys. It creates two filters one before the action and one after.
These do the following:
  
If the users session already has a 'session_keys' value it loads it into the ActiveRecord::Base.session_keys class field. If not it 
clears any existing session_keys.

Leaving the action it stores any session_keys in the corresponding session variable.

These filters are automatically enabled. You do not have to do anything.
  
To manually clear the session keys call clear_session_keys. This should be done for example as part of a session log off action.
=end      
    def self.append_features(base) #:nodoc:
      super
      base.send :prepend_before_filter, :load_session_keys
      base.send :prepend_after_filter, :save_session_keys      
    end

=begin rdoc
Clears the session keys. Call this when a user logs of.
=end
    def clear_session_keys
      ActiveRecord::Base.clear_session_keys
    end
    
    
    private
    def load_session_keys
      if session['session_keys']
        ActiveRecord::Base.session_keys=session['session_keys']
      else
        ActiveRecord::Base.clear_session_keys
      end
    end

    def save_session_keys
      if ActiveRecord::Base.session_keys.size>0
        session['session_keys']=ActiveRecord::Base.session_keys
      else
        session['session_keys']=nil
      end
    end
    

end

class MissingKeyError < RuntimeError
end 
end
ActiveRecord::Base.send :include, ActiveCrypto
require 'actionpack'
require 'action_controller'
ActionController::Base.send :include, ActiveCrypto::ActionController
