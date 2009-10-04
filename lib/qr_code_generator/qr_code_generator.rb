#--
# Copyright (c) 2009 by Scott W. Bradley (scottwb@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the above
# copyright notice is included.
#++

require 'rubygems'
require 'rqrcode'
require 'json'
require 'RMagick'

# The QRCodeGenerator module contains the QRCodeGenerator::QRCode class
# and a few module methods provided for convenience, for converting
# data objects into QR Codes.
#
#
# ==Example Usage
#
#   QRCodeGenerator.encode_to_image_file(
#     "hello world",
#     "hello.png",
#     :size => 500
#   )
#
#   {:hello => "world"}.to_qr.to_html(:size => 500)
#
#
# ==Core Extensions
#
# The QRCodeGenerator::CoreExtensions#to_qr method is added to core
# classes such as String, Hash, and Array, as well as ActiveRecord::Base.
# This allows you to simply do something like:
#
#   "hello world".to_qr
#
# to create a QRCodeGenerator::QRCode instance that you can then render
# to image or HTML with methods such as QRCodeGenerator::QRCode#to_image
# and QRCodeGenerator::QRCode#to_html.
#
#
# ==QR Code Options
#
# The QR Code generation methods that take "QR Code Options" can use the
# following options:
#
#   :min_size => The minimum size (QR Code type number) to generate the
#                QR Code. This size will be used unless it is not big enough
#                to hold the specified data, in which case, the smallest
#                size that is big enough to hold it will be used. This
#                Must be a number from 1 to 40. By default it is set to 1.
#
#   :level => The error correction level to encode the QR Code with. This
#             defaults to :h and can be one of the following values:
#
#               :l - 7% of the code can be restored.
#
#               :m - 15% of the code can be restored.
#
#               :q - 25% of the code can be restored.
#
#               :h - 30% of the code can be restored.
#
#   :encoding => When the data being encoded is not a String, this option
#                specifies what encoding to use to convert the data to
#                a Strings. This defaults to :json, and may be one of the
#                following values:
#
#                  :json - The data object is encoded using to_json.
#
#                  :xml - The data object is encoded using to_xml.
#
#                  :yaml - The data object is encoded using to_yaml.
#
#                  :marshal - The data object is encoded using Marshal.dump
#                             and then Base64.encode64.
#
#                  :string - The data object is encoded using to_s.
#
#
# ==Image Options
#
# The QR Code image generation methods that take "Image Options" can use
# the following options:
#
#   :size => The size, in pixels to generate the image to. This includes only
#            the actual QR Code image. The width and height of the image will
#            set to this value. By default, if this is unspecified, the
#            image will be generated as small as possible, using one pixel
#            per QR Code module.
#
#   :margin => The number of modules to add, in addition to :size, as a margin
#              around the image. This defaults to 4, as the QR Code
#              specification requires that there is a 4-module border around
#              the QR Code image. Note that this means the actual image
#              that is generated will be larger than the specified :size by
#              this margin.
#
#   :format => The image format to generate the image in. This defaults to
#              'png', and may be any of the format values supported by
#              RMagick, such as 'jpg', 'gif', etc.
#
#
# ==HTML Options
#
# The QR Code HTML generation methods that take "HTML Options" can use
# the following options:
#
#   :size => The approximate size, in pixels, to generate the HTML table
#            to. The generated HTML table will be approximately this wide
#            and high. This only includes the QR Code part of the output,
#            not the margin, and is only approximate since the number of
#            modules required to fit into this size might not be evenly
#            divisible into the :size. By default this is 200.
#
#   :margin => The number of modules to add, in addition to :size, as a
#              margin around the HTML table. This defaults to 4, as the
#              QR Code specification requires that there is a 4-module
#              border around the QR Code image. Note that this means the
#              actual HTML table that is generated will be larger than
#              the specified :size by this margin.
#
module QRCodeGenerator
  VERSION = "0.9.0"


  ############################################################
  # Default Options
  ############################################################
  
  # Default values for QR Code options.
  DEFAULT_QR_OPTIONS = {
    :min_size => 1,
    :level    => :h,
    :encoding => :json
  }
  
  # Default values for QR Code image output options.
  DEFAULT_IMG_OPTIONS = {
    :margin => 4,    # QR Code spec requries min. 4 "module" white margin.
    :size   => nil,  # Default to no scaling.
    :format => 'png'
  }

  # Default values for QR Code HTML output options.
  DEFAULT_HTML_OPTIONS = {
    :margin => 4,   # QR Code spec requires min. 4 "module" white margin.
    :size   => 200
  }


  ############################################################
  # QRCodeGenerator Module Methods
  ############################################################

  # Converts the specified +data+ into a QR Code string that represents
  # the QR Code as ASCII art so to speak, using an X for a black module
  # and a space for a white module.
  #
  # ====Parameters
  #
  # +data+::
  #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
  #
  # +options+::
  #   An optional Hash of options to affect the QR Code generation.
  #   See "QR Code Options".
  #
  # ====Returns
  #
  # A String that represents the +data+ encoded to a QR Code.
  #
  def QRCodeGenerator.encode_to_string(data, options = {})
    QRCode.new(data, options).to_s
  end

  # Converts the specified +data+ into a Magick::Image image object that
  # is a rendering of the +data+ encoded as a QR Code.
  #
  # ====Parameters
  #
  # +data+::
  #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
  #
  # +options+::
  #   An optional Hash of options to affect the QR Code image generation.
  #   These may include "QR Code Options" and "Image Options".
  #
  # ====Returns
  #
  # A Magick::Image object that represents the +data+ encoded to a
  # QR Code image.
  #
  def QRCodeGenerator.encode_to_image(data, options = {})
    QRCode.new(data, options).to_image(options)
  end
  
  # Converts the specified +data+ into binary image data that is a rendering
  # of the +data+ encoded as a QR Code.
  #
  # ====Parameters
  #
  # +data+::
  #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
  #
  # +options+::
  #   An optional Hash of options to affect the QR Code image generation.
  #   These may include "QR Code Options" and "Image Options".
  #
  # ====Returns
  #
  # A String that contains the generated binary image data representing
  # the +data+ encoded to a QR Code image.
  #
  def QRCodeGenerator.encode_to_image_blob(data, options = {})
    QRCode.new(data, options).to_image_blob(options)
  end
  
  # Converts the specified +data+ into an image file that is a rendering
  # of the +data+ encoded as a QR Code.
  #
  # ====Parameters
  #
  # +data+::
  #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
  #
  # +filename+::
  #   The path to the file to write the generated image to.
  #
  # +options+::
  #   An optional Hash of options to affect the QR Code image generation.
  #   These may include "QR Code Options" and "Image Options".
  #
  # ====Returns
  #
  # The Magick::Image object that was written to the specified file.
  #
  def QRCodeGenerator.encode_to_image_file(data, filename, options = {})
    QRCode.new(data, options).to_image_file(filename, options)
  end
  
  # Converts the specified +data+ into an HTML table that is a rendering
  # of the +data+ encoded as a QR Code.
  #
  # ====Parameters
  #
  # +data+::
  #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
  #
  # +options+::
  #   An optional Hash of options to affect the QR Code image generation.
  #   These may include "QR Code Options" and "HTML Options".
  #
  # ====Returns
  #
  # A String containing the generated HTML.
  #
  def QRCodeGenerator.encode_to_html(data, options = {})
    QRCode.new(data, options).to_html(options)
  end


  # An instance of the QRCodeGenerator::QRCode class represents a QR Code
  # that has been encoded from a data object. It supports methods
  # for rendering it in various ways.
  class QRCode

    ############################################################
    # Constants
    ############################################################
    MAX_QR_SIZE = 40  # As per the QR Spec.
    BLACK_PIXEL = 0
    WHITE_PIXEL = 255
    BLACK_CELL  = "#000000"
    WHITE_CELL  = "#FFFFFF"


    ############################################################
    # Accessors
    ############################################################
    attr_reader :data
    attr_reader :str
    attr_reader :width
    attr_reader :height


    ############################################################
    # Instance Methods
    ############################################################
    
    # Creates a new QRCode instance from the given +data+.
    #
    # ====Parameters:
    #
    # +data+::
    #   The data object, e.g.: a String, Hash, Array, etc. to be encoded.
    #
    # +options+::
    #   An optional Hash of options to affect the QR Code generation.
    #   See "QR Code Options".
    #
    # ====Returns
    #
    # The new QRCode instance.
    #
    def initialize(data, options = {})
      @data   = data
      @images = {}

      # Set the default options if they are unspecified.
      @options = DEFAULT_QR_OPTIONS.merge(options)

      # Convert the data to a string using the specified encoding method.
      @str = case data
             when String
               data
             else
               case @options[:encoding]
               when :json    then data.to_json
               when :xml     then data.to_xml
               when :yaml    then data.to_yaml
               when :marshal then Base64.encode64(Marshal.dump(data))
               when :string  then data.to_s
               else
                 raise "Invalid qr_encoding: #{@options[:encoding].inspect}"
               end
             end

      # Encode the data string to a QR Code.
      #
      # Try generate the QR Code at increasing size until we find one that fits.
      #
      # REVISIT: There must be a better way to precompute what size we need.
      #
      (@options[:min_size]..MAX_QR_SIZE).each do |size|
        begin
          @qr = RQRCode::QRCode.new(
            str,
            :size  => size,
            :level => @options[:level]
          )
          break
        rescue
          # Ignore and try next one.
        end
      end
      raise "Too much data to encode as a QR Code." if @qr.nil?

      @width  = @qr.module_count
      @height = @width
    end
    
    # Renders this QRCode as an "ASCII art" String, using an X for a black
    # module and a space for a white module.
    #
    # ====Parameters
    #
    # None.
    #
    # ====Returns
    #
    # The String-rendering of this QRCode.
    #
    def to_s
      @qr.to_s
    end
    
    # Renders this QRCode as an HTML table.
    #
    # ====Parameters
    #
    # +options+::
    #   An optional Hash containing options that affect the HTML generation.
    #   See "HTML Options".
    #
    # ====Returns
    #
    # A String containing the generated HTML.
    #
    def to_html(options = {})
      html = nil

      # Set the default options if they are unspecified.
      opts = DEFAULT_HTML_OPTIONS.merge(options)

      size   = opts[:size] / @width
      margin = size * opts[:margin]

      html =  "<table cellpadding=\"0\" cellspacing=\"0\">"
      
      html << "<tr>"
      html << "<td style=\"width:#{margin}px;height:#{margin}px;background-color:#{WHITE_CELL};\"></td>"
      @width.times do
        html << "<td style=\"width:#{size}px;height:#{margin}px;background-color:#{WHITE_CELL};\"></td>"
      end
      html << "<td style=\"width:#{margin}px;height:#{margin}\"></td>"
      html << "</tr>"

      (0...@height).each do |row|
        html << "<tr>"
        html << "<td style=\"width:#{size}px;height:#{size}px;background-color:#{WHITE_CELL};\"></td>"
        (0...@width).each do |col|
          html << "<td style=\"width:#{size}px;height:#{size}px;background-color:#{@qr.is_dark(row, col) ? BLACK_CELL : WHITE_CELL};\"></td>"
        end
        html << "<td style=\"width:#{size}px;height:#{size}px;background-color:#{WHITE_CELL};\"></td>"
        html << "</tr>"
      end

      html << "<tr>"
      html << "<td style=\"width:#{margin}px;height:#{margin}px;background-color:#{WHITE_CELL};\"></td>"
      @width.times do
        html << "<td style=\"width:#{size}px;height:#{margin}px;background-color:#{WHITE_CELL};\"></td>"
      end
      html << "<td style=\"width:#{margin}px;height:#{margin}\"></td>"
      html << "</tr>"

      html << "</table>"

      return html
    end
    
    # Renders this QRCode as a Magick::Image object.
    #
    # ====Parameters
    #
    # +options+::
    #   An optional Hash containing options that affect the image generation.
    #   See "Image Options".
    #
    # ====Returns
    #
    # A Magick::Image instance containing the rendered image.
    #
    def to_image(options = {})
      image = nil

      # Set the default options if they are unspecified.
      opts = DEFAULT_IMG_OPTIONS.merge(options)

      # Create a unique key by which this image is/will be cached
      # on this instance. We only need to generate a different image if
      # the margin is different.
      cache_key = opts[:margin].to_s

      # First try to Get the cached image. If it's not cached, then create it.
      image = @images[cache_key]
      if image.nil?
        # Figure out the size of the base image based on the number of
        # modules in the QR Code and the size of the margin.
        margin     = opts[:margin]
        img_width  = @width  + (2 * margin)
        img_height = @height + (2 * margin)
    
        # Make arrays of pixel data to use for the margins.
        vert_margin = [].fill(WHITE_PIXEL, 0, margin * img_width)
        horz_margin = [].fill(WHITE_PIXEL, 0, margin)

        # Convert QR Code to pixel data, starting with the top margin.
        pixels = vert_margin

        # Add each row of QR Code pixels prefixed and suffixed with the margin.
        #
        # REVISIT: Optimize.
        #
        (0...@height).each do |row|
          pixels += horz_margin
          (0...@width).each do |col|
            pixels << (@qr.is_dark(row, col) ? BLACK_PIXEL : WHITE_PIXEL)
          end
          pixels += horz_margin
        end

        # Add in the bottom margin
        pixels += vert_margin

        # Generate an RMagick image of the specified format from the pixel data.
        image = Magick::Image.new(img_width, img_height)
        image.import_pixels(
          0,
          0,
          img_width,
          img_height,
          "I",              # grayscale
          pixels,
          Magick::CharPixel # pixel range 0-255
        )

        # Store the new image in the cache.
        @images[cache_key] = image
      end
    
      # Now we have the base image. If an img_size is specified, try to
      # lookup a cached image at that size, or create a scaled copy of
      # the base image at that size if it doesn't exist, and then cache it.
      if opts[:size]
        cache_key = "#{opts[:margin]}/#{opts[:size]}"
        if @images.has_key?(cache_key)
          image = @images[cache_key]
        else
          image = image.sample(opts[:size], opts[:size])
          @images[cache_key] = image
        end
      end

      return image
    end

    # Renders this QRCode as binary image data.
    #
    # ====Parameters
    #
    # +options+::
    #   An optional Hash containing options that affect the image generation.
    #   See "Image Options".
    #
    # ====Returns
    #
    # A String that contains the generated binary image data representing
    # this QRCode.
    #
    def to_image_blob(options = {})
      # Set the default options if they are unspecified.
      opts = DEFAULT_IMG_OPTIONS.merge(options)

      return self.to_image(opts).to_blob do
        self.format = opts[:format]
      end
    end

    # Renders this QRCode to an image file.
    #
    # ====Parameters
    #
    # +filename+::
    #   The path to the file to write the generated image to. The extension
    #   of this filename is used to determine the image file format.
    #
    # +options+::
    #   An optional Hash containing options that affect the image generation.
    #   See "Image Options".
    #
    # ====Returns
    #
    # The Magick::Image object that was written to the specified file.
    #
    def to_image_file(filename, options = {})
      self.to_image(options).write(filename)
    end
  end
end
