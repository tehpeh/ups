module UPS
  module Parsers
    class VoidShipmentParser < ParserBase
      attr_accessor :identification_number, :shipment_digest

      def value(value)
        # if switch_active?(:ShipmentIdentificationNumber)
        #   self.identification_number = value.as_s
        # elsif switch_active?(:ShipmentDigest)
        #   self.shipment_digest = value.as_s
        # end
        super
      end
    end
  end
end
