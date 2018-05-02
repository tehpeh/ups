require 'ox'

module UPS
  module Builders
    # The {VoidShipmentBuilder} class builds UPS XML VoidShipment Objects.
    #
    # @author Paul Trippett
    # @since 0.1.0
    # @attr [String] name The Containing XML Element Name
    class VoidShipmentBuilder < BuilderBase
      include Ox

      attr_accessor :document1, :document2

      # Initializes a new {VoidShipmentBuilder} object
      #
      def initialize
        initialize_xml_roots 'VoidShipmentRequest'

        document1 << access_request
        document2 << root

        yield self if block_given?
        add_request '1', '1'
      end


      def add_shipment_identification_number(id_num)
        root << element_with_value('ShipmentIdentificationNumber', id_num)
      end

      def to_xml
        '<?xml version="1.0" encoding="UTF-8"?>' +
        Ox.to_xml(document1) +
        '<?xml version="1.0" encoding="UTF-8"?>' +
        Ox.to_xml(document2)
      end

      private

      def initialize_xml_roots(root_name)
        self.document1      = Document.new(version: '1.0', encoding: 'UTF-8')
        self.document2      = Document.new(version: '1.0', encoding: 'UTF-8')
        self.root           = Element.new(root_name)
        self.access_request = Element.new('AccessRequest')
      end

    end
  end
end
