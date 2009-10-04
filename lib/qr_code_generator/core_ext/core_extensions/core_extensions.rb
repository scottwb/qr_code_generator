module QRCodeGenerator
  # This module can be included on core classes such as String, Hash, Array,
  # etc. to extend them with these convenience methods for generating
  # QR Codes on them.
  module CoreExtensions

    # Converts this object to a QRCodeGenerator::QRCode instance that
    # represents this object encoded as a QRCode.
    #
    # ====Parameters
    #
    # +options+::
    #   An optional Hash of options to affect the QR Code generation.
    #   See the QRCodeGenerator "QR Code Options" documentation for details.
    #
    # ====Returns
    #
    # A QRCodeGenerator::QRCode instance that represents this object
    # encoded as a QRCode.
    #
    def to_qr(options = {})
      QRCodeGenerator::QRCode.new(self, options)
    end
  end
end
