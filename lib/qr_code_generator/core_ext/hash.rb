require File.dirname(__FILE__) + '/core_extensions/core_extensions.rb'

class Hash #:nodoc:
  include QRCodeGenerator::CoreExtensions
end
