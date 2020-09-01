require 'base64'
require 'tempfile'

module UPS
  module Parsers
    class ShipAcceptParser < BaseParser
      def tracking_number
        packages[0].tracking_number
      end

      def label_graphic_extension
        packages[0].label_graphic_extension
      end

      def label_graphic_image
        packages[0].label_graphic_image
      end

      def label_html_image
        packages[0].label_html_image
      end

      alias_method :graphic_extension, :label_graphic_extension
      alias_method :graphic_image, :label_graphic_image
      alias_method :html_image, :label_html_image

      def form_graphic_extension
        return unless has_form_graphic?

        ".#{form_graphic[:Image][:ImageFormat][:Code].downcase}"
      end

      def form_graphic_image
        return unless has_form_graphic?

        Utils.base64_to_file(form_graphic[:Image][:GraphicImage], form_graphic_extension)
      end

      def packages
        return package_results.map { |package_result| UPS::Models::PackageResult.new(package_result) } if package_results.is_a?(Array)

        [UPS::Models::PackageResult.new(package_results)]
      end
      
      def master_carton_id
        shipment_results[:MasterCartonID]
      end

      def total_cost 
        return shipment_charge unless negotiated_rate

        negotiated_rate
      end

      def negotiated_rate
        negotiated_rate_response && negotiated_rate_response[:NetSummaryCharges][:GrandTotal][:MonetaryValue].to_f
      end

      private

      def negotiated_rate_response
        shipment_results[:NegotiatedRates]
      end

      def shipment_charge
        shipment_results[:ShipmentCharges][:TotalCharges][:MonetaryValue].to_f
      end

      def form_graphic
        shipment_results[:Form]
      end

      def has_form_graphic?
        shipment_results.key?(:Form)
      end

      def package_results
        shipment_results[:PackageResults]
      end

      def shipment_results
        root_response[:ShipmentResults]
      end

      def root_response
        parsed_response[:ShipmentAcceptResponse]
      end
    end
  end
end
