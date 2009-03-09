# Radius Dictionary file reader
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
# $Id: dictionary.rb 2 2006-12-17 06:16:21Z dido $
#

module Radius
  # This is a simple class that can read RADIUS dictionary files and
  # parse them, allowing conversion between dictionary names and
  # numbers.  Vendor-specific attributes are supported in a way
  # consistent with the standards.
  #
  # This class is patterned after the Net::Radius::Dictionary Perl
  # module written by Christopher Masto (mailto:chris@netmonger.net)
  # and Luis E. Munoz (mailto:lem@cantv.net)
  class Dict
    # Initialize all the instance variables.  All variables
    # start out as empty versions of the appropriate type.
    def initialize
      @attr = Hash.new(nil)
      @rattr = Array.new
      @val = Array.new
      @rval = Array.new
      @vsattr = Array.new
      @rvsattr = Array.new
      @vsaval = Array.new
      @rvsaval = Array.new
    end

    # Parse a dictionary file from an IO object and learn the
    # name<->number mappings from it.  Only the /first/ definition
    # will apply if multiple definitions are seen.  This method may be
    # called multiple times with different IO objects, reading from
    # several files.
    #
    # ====Parameters
    #
    # +fp+:: IO object from which to read the data
    #
    # ====Return
    # None.  Any strangeness in the file results in a message being
    # printed to stderr.
    def read(fp)
      fp.each_line {
	|line|
	next if line =~ /^\#/	# discard comments
	next if (sl = line.split(/\s+/)) == []
	case sl[0].upcase
	when "ATTRIBUTE"
	  @attr[sl[1]] = [sl[2].to_i, sl[3]] if (@attr[sl[1]] == nil)
	  @rattr[sl[2].to_i] = [sl[1], sl[3]] if (@rattr[sl[2].to_i] == nil)
	when "VALUE"
	  if (@attr[sl[1]] == nil)
	    $stderr.print("Warning: value given for unknown attribute #{sl[1]}");
	  else
	    if (@val[@attr[sl[1]][0]] == nil)
	      @val[@attr[sl[1]][0]] = {}
	    end
	    if (@rval[@attr[sl[1]][0]] == nil)
	      @rval[@attr[sl[1]][0]] = []
	    end
	    if (@val[@attr[sl[1]][0]][sl[2]] == nil)
	      @val[@attr[sl[1]][0]][sl[2]] = sl[3].to_i
	    end
	    if (@rval[@attr[sl[1]][0]][sl[3].to_i] == nil)
	      @rval[@attr[sl[1]][0]][sl[3].to_i] = sl[2]
	    end
	  end
	when "VENDORATTR"
	  sl[3] = Kernel::Integer(sl[3]) # this gets hex and octal
				# values correctly
	  @vsattr[sl[1].to_i] = {} if (@vsattr[sl[1].to_i] == nil)
	  @rvsattr[sl[1].to_i] = {} if (@rvsattr[sl[1].to_i] == nil)

	  if (@vsattr[sl[1].to_i][sl[2]] == nil)
	    @vsattr[sl[1].to_i][sl[2]] = sl[3..4]
	  end

	  if (@rvsattr[sl[1].to_i][sl[3]] == nil)
	    @rvsattr[sl[1].to_i][sl[3]] = [sl[2], sl[4]]
	  end
	when "VENDORVALUE"
	  sl[4] = Kernel::Integer(sl[4])
	  if (@vsattr[sl[1].to_i][sl[2]] == nil)
	    $stderr.print "Warning: vendor value for unknown vendor attribute #{sl[1]} found - ignored\n"
	  else
	    sl[1] = sl[1].to_i
	    @vsaval[sl[1]] = {} if @vsaval[sl[1].to_i] == nil
	    @rvsaval[sl[1]] = {} if @rvsaval[sl[1].to_i] == nil
	    if @vsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]] == nil
	      @vsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]] = {}
	    end

	    if @rvsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]] == nil
	      @rvsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]] = []
	    end

	    if @vsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]][sl[3]] == nil
	      @vsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]][sl[3]] = sl[4]
	    end

	    if @rvsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]][sl[4]] == nil
	      @rvsaval[sl[1]][@vsattr[sl[1]][sl[2]][0]][sl[4]] = sl[3]
	    end
	  end
	else
	  $stderr.print "Warning: Weird dictionary line: #{line}\n"
	end
      }
    end

    # Given an attribute name, return the number corresponding to it,
    # based on the dictionary file(s) that have been read.
    #
    # ====Parameters
    # +attrname+:: Name of the attribute whose number is desired.
    #
    # ====Return Value
    # The number corresponding to the appropriate attribute name
    # given.
    def attr_num(attrname)
      if (@attr[attrname] == nil || @attr[attrname][0] == nil)
	return(nil)
      end
      return(@attr[attrname][0])
    end

    # Given an attribute name, return the corresponding type for it,
    # based on the dictionary file(s) that have been read.
    #
    # ====Parameters
    # +attrname+:: Name of the attribute whose type is desired.
    #
    # ====Return Value
    # The type string corresponding to the appropriate attribute name
    # given.  This is either string, ipaddr, integer, or date.
    def attr_type(attrname)
      if (@attr[attrname] == nil || @attr[attrname][1] == nil)
	return(nil)
      end
      return(@attr[attrname][1])
    end

    # Given an attribute number, return the name corresponding to it,
    # based on the dictionary file(s) that have been read, the reverse
    # of the attr_num method.
    #
    # ====Parameters
    # +attrname+:: Name of the attribute whose number is desired.
    #
    # ====Return Value
    # The number corresponding to the appropriate attribute name
    # given.
    def attr_name(attrnum)
      if (@rattr[attrnum] == nil || @rattr[attrnum][0] == nil)
	return(nil)
      end
      return(@rattr[attrnum][0])
    end

    # Given an attribute number, return the type of the attribute
    # corresponding to it, based on the dictionary file(s) that have
    # been read.
    #
    # ====Parameters
    # +attrnum+:: Number of the attribute whose type is desired.
    #
    # ====Return Value
    # The number corresponding to the appropriate attribute name
    # given.
    def attr_numtype(attrnum)
      if (@rattr[attrnum] == nil || @rattr[attrnum][1] == nil)
	return(nil)
      end
      return(@rattr[attrnum][1])
    end

    # Given an attribute number, return true or false depending on
    # whether or not a value has been given for it.
    #
    # ====Parameters
    # +attrnum+:: Number of the attribute whose definition is known
    #
    # ====Return Value
    # True or false depending on whether some value has been given to
    # the attribute
    def attr_has_val(attrnum)
      return(@val[attrnum] != nil)
    end

    # Alias for attr_has_val.  Don't use this; it's confusing.
    #
    # ====Parameters
    # +attrname+:: Name of the attribute whose number is desired.
    #
    # ====Return Value
    # The number corresponding to the appropriate attribute name
    # given.
    def val_has_name(attrnum)
      return(@rval[attrnum] != nil)
    end

    # Give the number of the named value for the attribute number
    # supplied.
    #
    # ====Parameters
    # +attrnum+:: the attribute number
    # +valname+:: the name of the value
    # ====Return
    # The number of the named value and attribute.
    def val_num(attrnum, valname)
      return(@val[attrnum][valname])
    end

    # Returns the name of the numbered value for the attribute value
    # supplied.  The reverse of val_num.
    #
    # ====Parameters
    # +attrnum+:: the attribute number
    # +valname+:: the name of the value
    # ====Return
    # The name of the numbered value and attribute.
    def val_name(attrnum, valnum)
      return(@rval[attrnum][valnum])
    end

    # Obtains the code of a vendor-specific attribute given the
    # Vendor-Id and the name of the vendor-specific attribute (e.g. 9
    # for Cisco and 'cisco-avpair').
    #
    # =====Parameters
    # +vendorid+:: the Vendor-Id
    # +name+:: the name of the vendor-specific attribute to query
    # =====Return Value
    # The code for the vendor-specific attribute
    def vsattr_num(vendorid, name)
      return(@vsattr[vendorid][name][0])
    end

    # Obtains the type of a vendor-specific attribute given the
    # Vendor-Id and the name of the vendor-specific attribute.
    #
    # =====Parameters
    # +vendorid+:: the Vendor-Id
    # +name+:: the name of the vendor-specific attribute to query
    # =====Return Value
    # The type for the vendor-specific attribute
    def vsattr_type(vendorid, name)
      return(@vsattr[vendorid][name][1])
    end

    # Obtains the name of a vendor-specific attribute given the
    # Vendor-Id and the code of the vendor-specific attribute.  The
    # inverse of vsattr_num.
    #
    # =====Parameters
    # +vendorid+:: the Vendor-Id
    # +code+:: the code of the vendor-specific attribute to query
    # =====Return Value
    # The name of the vendor-specific attribute
    def vsattr_name(vendorid, code)
      return(@rvsattr[vendorid][code][0])
    end

    # Obtains the type of a vendor-specific attribute given the
    # Vendor-Id and the code of the vendor-specific attribute.
    #
    # =====Parameters
    # +vendorid+:: the Vendor-Id
    # +code+:: the code of the vendor-specific attribute to query
    # =====Return Value
    # The type of the vendor-specific attribute
    def vsattr_numtype(vendorid, code)
      return(@rvsattr[vendorid][code][1])
    end

    # Determines whether the vendor-specific attibute with the
    # Vendor-Id and code given has a value.
    # =====Parameters
    # +vendorid+:: the Vendor-Id
    # +code+:: the code of the vendor-specific attribute to query
    # =====Return Value
    # True or false on whether or not the vendor-specific attribute
    # has a value
    def vsattr_has_val(vendorid, code)
      return(@vsaval[vendorid][code] != nil)
    end

    # Alias for vsattr_has_val.  Don't use this; it's confusing.
    #
    # ====Parameters
    # +vendorid+:: the Vendor-Id
    # +attrnum+:: Name of the attribute whose number is desired.
    #
    # ====Return Value
    # The number corresponding to the appropriate attribute name
    # given.
    def vsaval_has_name(vendorid, attrnum)
      return(@rvsaval[vendorid][attrnum] != nil)
    end

    # Give the number of the named value for the vendor-specific
    # attribute number supplied.
    #
    # ====Parameters
    # +vendorid+:: the Vendor-Id
    # +attrnum+:: the attribute number
    # +valname+:: the name of the value
    # ====Return
    # The number of the named value and attribute.
    def vsaval_num(vendorid, attrnum, valname)
      return(@vsaval[vendorid][attrnum][valname])
    end

    # Returns the name of the numbered value for the vendor-specific
    # attribute value supplied.  The reverse of val_num.
    #
    # ====Parameters
    # +vendorid+:: the vendor ID
    # +attrnum+:: the attribute number
    # +valname+:: the name of the value
    # ====Return
    # The name of the numbered value and attribute.
    def vsaval_name(vendorid, attrnum, valnum)
      return(@rvsaval[vendorid][attrnum][valnum])
    end
  end
end
