#!/usr/bin/env ruby

require 'test/unit'
require 'qr_code_generator'
require File.dirname(__FILE__) + '/helpers'

class TestBasic < Test::Unit::TestCase
  def test_should_be_able_to_be_loaded_via_require
    # Do nothing. We won't even get this far if it can't be loaded.
    # This is really just to test the test harness and the agiledox task.
  end

  def test_should_encode_to_string_with_default_options
    s = QRCodeGenerator.encode_to_string("Hello World")
    assert_not_nil(s)
    assert_kind_of(String, s)
  end

  def test_should_encode_to_image_with_default_options
    img = QRCodeGenerator.encode_to_image("Hello World")
    assert_not_nil(img)
    assert_kind_of(Magick::Image, img)
  end

  def test_should_encode_to_image_block_with_default_options
    b = QRCodeGenerator.encode_to_image_blob("Hello World")
    assert_not_nil(b)
    assert_kind_of(String, b)
  end

  def test_should_encode_to_image_file_with_default_options
    img = QRCodeGenerator.encode_to_image_file("Hello World", 'test.png')
    assert_not_nil(img)
    assert_kind_of(Magick::Image, img)
    assert(File.exists?('test.png'))
    File.unlink('test.png')
  end

  def test_should_encode_to_html_with_default_options
    html = QRCodeGenerator.encode_to_html("Hello World")
    assert_not_nil(html)
    assert_kind_of(String, html)
    assert_match(/table/, html)
  end
                 
end
