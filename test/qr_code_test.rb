#!/usr/bin/env ruby

require 'test/unit'
require 'qr_code_generator'
require File.dirname(__FILE__) + '/helpers'

class TestBasic < Test::Unit::TestCase

  def test_should_be_able_to_instantiate_with_default_options
    qr = QRCodeGenerator::QRCode.new("Hello World")
    assert_not_nil(qr)
    assert_kind_of(QRCodeGenerator::QRCode, qr)
  end

end
