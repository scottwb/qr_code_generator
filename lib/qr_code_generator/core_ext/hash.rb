#--
# Copyright (c) 2009 by Scott W. Bradley (scottwb@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the above
# copyright notice is included.
#++

require File.dirname(__FILE__) + '/core_extensions/core_extensions.rb'

class Hash #:nodoc:
  include QRCodeGenerator::CoreExtensions
end
