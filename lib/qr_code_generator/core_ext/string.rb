require File.dirname(__FILE__) + '/core_extensions/core_extensions.rb'

class String #:nodoc:
  include QRCodeGenerator::CoreExtensions
end
