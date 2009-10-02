require File.dirname(__FILE__) + '/../core_ext/core_extensions/core_extensions.rb'

module ActiveRecord #:nodoc:
  class Base #:nodoc:
    include QRCodeGenerator::CoreExtensions
  end
end
