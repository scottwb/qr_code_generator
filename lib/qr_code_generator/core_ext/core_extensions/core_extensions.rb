module QRCodeGenerator
  module CoreExtensions
    def to_qr(options = {})
      QRCodeGenerator::QRCode.new(self, options)
    end
  end
end
