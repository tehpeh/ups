module UPS
  module Parsers
    class VoidShipmentParser < ParserBase
      attr_accessor :identification_number, :shipment_digest

      def value(value)
        super
      end
    end
  end
end
