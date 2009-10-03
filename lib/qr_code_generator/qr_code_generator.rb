require 'rqrcode'
require 'RMagick'

# The QRCodeGenerator class contains...TODO: document this.
#
# TODO:
#   [X] Turn into class model.
#   [X] Make image margin configurable.
#   [ ] Add HTML table generation.
#   [X] Add to_qr methods to Strings, Hash, and Array.
#   [X] Maybe add to_qr to ActiveRecord::Base
#   [ ] Write docs.
#   [ ] Figure out a better way to compute the min size that trial and error.
#   [ ] Make into a plugin gem. Make it have a dependency on rqrcode.
#   [ ] Cleanup REVISITs
#   [ ] Check in to github.
#   [ ] Build test cases or maybe even rspec for the plugin.
#   [ ] Add rdoc/ri tasks.
#   [ ] Submit to rubyforge?
#
module QRCodeGenerator
  class QRCode

    ############################################################
    # Configuration
    ############################################################
    DEFAULT_QR_OPTIONS = {
      :qr_min_size => 1,
      :qr_level    => :h,
      :qr_encoding => :json
    }

    DEFAULT_IMG_OPTIONS = {
      :img_margin => 4,    # QR Code spec requries min. 4 "module" white margin.
      :img_size   => nil,  # Default to no scaling.
      :img_format => 'png'
    }


    ############################################################
    # Constants
    ############################################################
    MAX_QR_SIZE = 40  # As per the QR Spec.
    BLACK_PIXEL = 0
    WHITE_PIXEL = 255


    ############################################################
    # Accessors
    ############################################################
    attr_reader :data
    attr_reader :str
    attr_reader :width
    attr_reader :height


    ############################################################
    # Class Methods
    ############################################################
    def self.encode_to_string(data, options = {})
      self.new(data, options).to_s
    end

    def self.encode_to_image(data, options = {})
      self.new(data, options).to_image(options)
    end

    def self.encode_to_image_blob(data, options = {})
      self.new(data, options).to_image_blob(options)
    end

    def self.encode_to_image_file(data, filename, options = {})
      self.new(data, options).to_image_file(filename, options)
    end
                                          
  
    ############################################################
    # Instance Methods
    ############################################################

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
               case @options[:qr_encoding]
               when :json    then data.to_json
               when :xml     then data.to_xml
               when :yaml    then data.to_yaml
               when :marshal then Base64.encode64(Marshal.dump(data))
               when :string  then data.to_s
               else
                 raise "Invalid qr_encoding: #{@options[:qr_encoding].inspect}"
               end
             end

      # Encode the data string to a QR Code.
      #
      # Try generate the QR Code at increasing size until we find one that fits.
      #
      # REVISIT: There must be a better way to precompute what size we need.
      #
      (@options[:qr_min_size]..MAX_QR_SIZE).each do |size|
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

    def to_s
      @qr.to_s
    end

    def to_image(options = {})
      image = nil

      # Set the default options if they are unspecified.
      opts = DEFAULT_IMG_OPTIONS.merge(options)

      # Create a unique key by which this image is/will be cached
      # on this instance. We only need to generate a different image if
      # the margin is different.
      cache_key = opts[:img_margin].to_s

      # First try to Get the cached image. If it's not cached, then create it.
      image = @images[cache_key]
      if image.nil?
        # Figure out the size of the base image based on the number of
        # modules in the QR Code and the size of the margin.
        margin     = opts[:img_margin]
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
      if opts[:img_size]
        cache_key = "#{opts[:img_margin]}/#{opts[:img_size]}"
        if @images.has_key?(cache_key)
          image = @images[cache_key]
        else
          image = image.sample(opts[:img_size], opts[:img_size])
          @images[cache_key] = image
        end
      end

      return image
    end

    def to_image_blob(options = {})
      # Set the default options if they are unspecified.
      opts = DEFAULT_IMG_OPTIONS.merge(options)

      return self.to_image(opts).to_blob do
        self.format = opts[:img_format]
      end
    end

    def to_image_file(filename, options = {})
      self.to_image(options).write(filename)
    end
  end
end
