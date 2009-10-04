#--
# Copyright (c) 2009 by Scott W. Bradley (scottwb@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the above
# copyright notice is included.
#++

[
  'qr_code_generator',
  'core_ext',
  'rails'
].each do |f|
  require File.dirname(__FILE__) + "/qr_code_generator/#{f}"
end
