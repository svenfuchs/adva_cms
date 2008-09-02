# Radius Authentication Module for Ruby
#  Copyright (C) 2002 Rafael R. Sevilla <dido@imperium.ph>
#  This file is part of the Radius Authentication Module for Ruby
#
#  The Radius Authentication Module for Ruby is free software; you can
#  redistribute it and/or modify it under the terms of the GNU Lesser
#  General Public License as published by the Free Software
#  Foundation; either version 2.1 of the License, or (at your option)
#  any later version.
#
#  The Radius Authentication Module is distributed in the hope that it
#  will be useful, but WITHOUT ANY WARRANTY; without even the implied
#  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with the GNU C Library; if not, write to the Free
#  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
#  02111-1307 USA.
#
# Author:: Rafael R. Sevilla (mailto:dido@imperium.ph)
# Copyright:: Copyright (c) 2002 Rafael R. Sevilla
# License:: GNU Lesser General Public License
#
# $Id: packet.rb 2 2006-12-17 06:16:21Z dido $
#

module Radius
  # RADIUS (RFC 2138) specifies a binary packet format which contains
  # various values and attributes.  This class provides an interface
  # to turn RADIUS packets into Ruby data structures and vice-versa.
  #
  # Note that the Radius::Packet module does <em>not</em> provide
  # methods for obtaining or transmitting RADIUS packets to and from
  # the network.  A client of this module must provide that for
  # himself or herself.
  #
  # This class is patterned after the Net::Radius::Packet Perl
  # module written by Christopher Masto (mailto:chris@netmonger.net).
  require 'digest/md5'
  require 'radius/dictionary'

  class Packet
    # The code field is returned as a string.  As of this writing, the
    # following codes are recognized:
    #
    #   Access-Request          Access-Accept
    #   Access-Reject           Accounting-Request
    #   Accounting-Response     Access-Challenge
    #   Status-Server           Status-Client
    attr_reader :code

    # The code may be set to any of the strings described above in the
    # code attribute reader.
    attr_writer :code

    # The one-byte Identifier used to match requests and responses is
    # obtained as a character.
    attr_reader :identifier

    # The Identifer used to match RADIUS requests and responses can
    # also be directly set using this.
    attr_writer :identifier

    # The 16-byte Authenticator field can be read as a character
    # string with this attribute reader.
    attr_reader :authenticator
    # The authenticator field can be changed with this attribute
    # writer.
    attr_writer :authenticator

    # To initialize the object, pass a Radius::Dictionary object to it.
    def initialize(dict)
      @dict = dict
      @attributes = Hash.new(nil)
      @vsattributes = Array.new
    end

    private
    # I'd like to think that these methods should be built in
    # the Socket class
    def inet_aton(hostname)
      if (hostname =~ /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/)
	return((($1.to_i & 0xff) << 24) + (($2.to_i & 0xff) << 16) +
	       (($3.to_i & 0xff) << 8) + (($4.to_i & 0xff)))
      end
      return(0)
    end

    def inet_ntoa(iaddr)
      return(sprintf("%d.%d.%d.%d", (iaddr >> 24) & 0xff, (iaddr >> 16) & 0xff,
		     (iaddr >> 8) & 0xff, (iaddr) & 0xff))
    end

    public

    VSA_TYPE = 26		# type given to vendor-specific attributes
				# in RFC 2138

    # Given a raw RADIUS packet <tt>data</tt>, unpacks its contents so
    # it can be analyzed with other methods, (e.g. +code+, +attr+,
    # etc.).  It also clears all present attributes.
    #
    # =====Parameters
    # +data+:: The raw RADIUS packet to decode
    def unpack(data)
      p_hdr = "CCna16a*"
      rcodes = {
	1 => 'Access-Request',
	2  => 'Access-Accept',
	3  => 'Access-Reject',
	4  => 'Accounting-Request',
	5  => 'Accounting-Response',
	11 => 'Access-Challenge',
	12 => 'Status-Server',
	13 => 'Status-Client'
      }

      @code, @identifier, len, @authenticator, attrdat = data.unpack(p_hdr)
      @code = rcodes[@code]

      unset_all

      while (attrdat.length > 0)
	length = attrdat.unpack("xC")[0].to_i
	tval, value = attrdat.unpack("Cxa#{length-2}")

	tval = tval.to_i
	if (tval == VSA_TYPE)
	  # handle vendor-specific attributes
	  vid, vtype, vlength = value.unpack("NCC")
	  # XXX - How do we calculate the length of the VSA?  It's not
	  # defined!

	  # XXX - 3COM seems to do things a bit differently.  The 'if'
	  # below takes care of that.  This is based on the
	  # Net::Radius code.
	  if vid == 429
	    # 3COM packet
	    vid, vtype = value.unpack("NN")
	    vvalue = value.unpack("xxxxxxxxa#{length - 10}")[0]
	  else
	    vvalue = value.unpack("xxxxxxa#{vlength - 2}")[0]
	  end
	  type = @dict.vsattr_numtype(vid, vtype)
	  if type == nil
	    raise "Garbled vendor-specific attribute #{vid}/#{vtype}"
	  end
	  val = case type
		when 'string' then vvalue
		when 'integer'
		  (@dict.vsaval_has_name(vid, vtype)) ?
		  @dict.vsaval_name(vid, vtype, vvalue.unpack("N")[0]) :
		    vvalue.unpack("N")[0]
		when 'ipaddr' then inet_ntoa(vvalue)
		when 'time' then vvalue.unpack("N")[0]
		when 'date' then vvalue.unpack("N")[0]
		else
		  raise "Unknown VSattribute type found: #{vtype}"
		end
	  set_vsattr(vid, @dict.vsattr_name(vid, vtype), val)
	else
	  type = @dict.attr_numtype(tval)
	  raise "Garbled attribute #{tval}" if (type == nil)
	  val = case type
		when 'string' then value
		when 'integer'
		  @dict.val_has_name(tval) ?
		  @dict.val_name(tval, value.unpack("N")[0]) :
		    value.unpack("N")[0]
		when 'ipaddr' then inet_ntoa(value.unpack("N")[0])
		when 'time' then value.unpack("N")[0]
		when 'date' then value.unpack("N")[0]
		else raise "Unknown attribute type found: #{type}"
		end
	  set_attr(@dict.attr_name(tval), val)
	end
	attrdat[0, length] = ""
      end
    end

    # The Radius::Packet object contains attributes that can be set
    # and altered with the object's accessor methods, or obtained from
    # the unpack method.  This method will return a raw RADIUS
    # packet that should be suitable for sending to a RADIUS client or
    # server over UDP as per RFC 2138.
    #
    # =====Return Value
    # The RADIUS packet corresponding to the object's current internal
    # state.
    def pack
      hdrlen = 1 + 1 + 2 + 16	# size of packet header
      p_hdr = "CCna16a*"	# pack template for header
      p_attr = "CCa*"		# pack template for attribute
      p_vsa = "CCNCCa*"		# pack template for VSA's
      p_vsa_3com = "CCNNa*"	# used by 3COM devices

      codes = {
	'Access-Request' => 1,
	'Access-Accept' => 2,
	'Access-Reject' => 3,
	'Accounting-Request' => 4,
	'Accounting-Response' => 5,
	'Access-Challenge' => 11,
	'Status-Server' => 12,
	'Status-Client' => 13 }
      attstr = ""
      each {
	|attr, value|
	anum = @dict.attr_num(attr)
	val = case @dict.attr_type(attr)
	      when "string" then value
	      when "integer"
		[@dict.attr_has_val(anum) ?
	         @dict.val_num(anum, value) : value].pack("N")
	      when "ipaddr" then [inet_aton(value)].pack("N")
	      when "date" then [value].pack("N")
	      when "time" then [value].pack("N")
	      else
		next
	      end
	attstr += [@dict.attr_num(attr), val.length + 2, val].pack(p_attr)
      }

      # Pack vendor-specific attributes
      each_vsa {
	|vendor, attr, datum|
	code = @dict.vsattr_num(vendor, attr)
	vval = case @dict.vsattr_type(vendor, attr)
	       when "string" then datum
	       when "integer"
		 @dict.vsattr_has_val(vendor.to_i, code) ?
		 [@dict.vsaval_num(vendor, code, datum)].pack("N") :
		   [datum].pack("N")
	       when "ipaddr" then inet_aton(datum)
	       when "time" then [datum].pack("N")
	       when "date" then [datum].pack("N")
	       else next
	       end
	if vendor == 429
	  # For 3COM devices
	  attstr += [VSA_TYPE, vval.length + 10, vendor,
	    @dict.vsattr_num(vendor, attr), vval].pack(p_vsa_3com)
	else
	  attstr += [VSA_TYPE, vval.length + 8, vendor,
	    @dict.vsattr_num(vendor, attr), vval.length + 2,
	    vval].pack(p_vsa)
	end
      }

      return([codes[@code], @identifier, attstr.length + hdrlen,
	       @authenticator, attstr].pack(p_hdr))
    end

    # This method is provided a block which will pass every
    # attribute-value pair currently available.
    def each
      @attributes.each_pair {
	|key, value|
	yield(key, value)
      }
    end

    # The value of the named attribute in the object's internal state
    # can be obtained.
    #
    # ====Parameters
    # +name+:: the name of the attribute to obtain
    #
    # ====Return value:
    # The value of the attribute is returned.
    def attr(name)
      return(@attributes[name])
    end

    # Changes the value of the named attribute.
    #
    # ====Parameters
    # +name+:: The name of the attribute to set
    # +value+:: The value of the attribute
    def set_attr(name, value)
      @attributes[name] = value
    end

    # Undefines the current value of the named attribute.
    #
    # ====Parameters
    # +name+:: The name of the attribute to unset
    def unset_attr(name)
      @attributes[name] = nil
    end

    # Undefines all attributes.
    #
    def unset_all_attr
      each {
	|key, value|
	unset_attr(key)
      }
    end

    # This method will pass each vendor-specific attribute available
    # to a passed block.  The parameters to the block are the vendor
    # ID, the attribute name, and the attribute value.
    def each_vsa
      @vsattributes.each_index {
	|vendorid|
	if @vsattributes[vendorid] != nil
	  @vsattributes[vendorid].each_pair {
	    |key, value|
	    value.each {
	      |val|
	      yield(vendorid, key, val)
	    }
	  }
	end
      }
    end

    # This method is an iterator that passes each vendor-specific
    # attribute associated with a vendor ID.
    def each_vsaval(vendorid)
      @vsattributes[vendorid].each_pair {
	|key, value|
	yield(key, value)
      }
    end

    # Changes the value of the named vendor-specific attribute.
    #
    # ====Parameters
    # +vendorid+:: The vendor ID for the VSA to set
    # +name+:: The name of the attribute to set
    # +value+:: The value of the attribute
    def set_vsattr(vendorid, name, value)
      if @vsattributes[vendorid] == nil
	@vsattributes[vendorid] = Hash.new(nil)
      end
      if @vsattributes[vendorid][name] == nil
	@vsattributes[vendorid][name] = Array.new
      end
      @vsattributes[vendorid][name].push(value)
    end

    # Undefines the current value of the named vendor-specific
    # attribute.
    #
    # ====Parameters
    # +vendorid+:: The vendor ID for the VSA to set
    # +name+:: The name of the attribute to unset
    def unset_vsattr(vendorid, name)
      return if @vsattributes[vendorid] == nil
      @vsattributes[name] = nil
    end

    # Undefines all vendor-specific attributes.
    #
    def unset_all_vsattr
      each_vsa {
	|vendor, attr, datum|
	unset_vsattr(vendor, attr)
      }
    end

    # Undefines all regular and vendor-specific attributes
    def unset_all
      unset_all_attr
      unset_all_vsattr
    end

    # This method obtains the value of a vendor-specific attribute,
    # given the vendor ID and the name of the vendor-specific
    # attribute.
    # ====Parameters
    # +vendorid+:: the vendor ID
    # +name+:: the name of the attribute to obtain
    #
    # ====Return value:
    # The value of the vendor-specific attribute is returned.
    def vsattr(vendorid, name)
      return(nil) if @vsattributes[vendorid] == nil
      return(@vsattributes[vendorid][name])
    end

    private

    # Exclusive-or character by character two strings.
    # returns a new string that is the xor of str1 and str2.  The
    # two strings must be the same length.
    def xor_str(str1, str2)
      i = 0
      newstr = ""
      str1.each_byte {
	|c1|
	c2 = str2[i]
	newstr = newstr << (c1 ^ c2)
	i = i+1
      }
      return(newstr)
    end

    public

    # The RADIUS User-Password attribute is encoded with a shared
    # secret.  This method will return the decoded version given the
    # shared secret.  This also works when the attribute name is
    # 'Password' for compatibility reasons.
    # ====Parameters
    # +secret+:: The shared secret of the RADIUS system
    # ====Return
    # The cleartext version of the User-Password.
    def password(secret)
      pwdin = attr("User-Password") || attr("Password")
      pwdout = ""
      lastround = @authenticator
      0.step(pwdin.length-1, 16) {
	|i|
	pwdout = xor_str(pwdin[i, 16],
			 Digest::MD5.digest(secret + lastround))
	lastround = pwdin[i, 16]
      }
      pwdout.sub(/\000+$/, "") if pwdout
      pwdout[length.pwdin, -1] = "" unless (pwdout.length <= pwdin.length)
      return(pwdout)
    end

    # The RADIUS User-Password attribute is encoded with a shared
    # secret.  This method will prepare the encoded version of the
    # password.  Note that this method <em>always</em> stores the
    # encrypted password in the 'User-Password' attribute.  Some
    # (non-RFC 2138-compliant) servers have been reported that insist
    # on using the 'Password' attribute instead.
    #
    # ====Parameters
    # +passwd+:: The password to encrypt
    # +secret+:: The shared secret of the RADIUS system
    #
    def set_password(pwdin, secret)
      lastround = @authenticator
      pwdout = ""
      # pad to 16n bytes
      pwdin += "\000" * (15-(15 + pwdin.length) % 16)
      0.step(pwdin.length-1, 16) {
	|i|
	lastround = xor_str(pwdin[i, 16],
			    Digest::MD5.digest(secret + lastround))
	pwdout += lastround
      }
      set_attr("User-Password", pwdout)
      return(pwdout)
    end

    # This method will convert a RADIUS packet into a printable
    # string.  Any fields in the packet that might possibly contain
    # non-printable characters are turned into Base64 strings.
    #
    # ====Parameters
    # +secret+:: The shared secret of the RADIUS system.  Pass nil if
    # you don't want to see <tt>User-Password</tt> attributes decoded.
    #
    # ====Return
    # The string representation of the RADIUS packet.
    #
    def to_s(secret)
      str = "RAD-Code = #{@code}\n"
      str += "RAD-Identifier = #{@identifier}\n"
      str += "RAD-Authenticator = #{[@authenticator].pack('m')}"
      each {
	|attr, val|
	if (attr == 'User-Password')
	    val = (secret == nil) ? "(hidden)" : password(secret)
	end
	str += "#{attr} = #{val}\n"
      }

      each_vsa {
	|vendorid, vsaname, val|
	str += "Vendor-Id: #{vendorid} -- #{vsaname} = #{val}\n"
      }
      return(str)
    end

    # Given a (packed) RADIUS packet and a shared secret, returns a
    # new packet with the authenticator field changed in accordance
    # with RADIUS protocol requirements.
    #
    # ====Parameters
    # +packed_packet+:: The packed packet to compute a new Authenticator field for.
    # +secret+:: The shared secret of the RADIUS system.
    # ====Return value
    # a new packed packet with the authenticator field recomputed.
    def Packet.auth_resp(packed_packet, secret)
      new = String.new(packed_packet)
      new[4, 16] = Digest::MD5.digest(packed_packet + secret)
      return(new)
    end

  end
end
