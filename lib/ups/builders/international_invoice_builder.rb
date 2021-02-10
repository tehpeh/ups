require 'ox'

module UPS
  module Builders
    # The {InternationalInvoiceBuilder} class builds UPS XML International invoice Objects.
    #
    # @author Calvin Hughes
    # @since 0.9.3
    # @attr [String] name The Containing XML Element Name
    # @attr [Hash] opts The international invoice parts
    class InternationalInvoiceBuilder < BuilderBase
      include Ox

      attr_accessor :name, :opts

      def initialize(name, opts = {})
        self.name = name
        self.opts = opts
      end

      def form_type
        element_with_value('FormType', '01')
      end

      def invoice_number
        element_with_value('InvoiceNumber', opts[:invoice_number])
      end

      def invoice_date
        element_with_value('InvoiceDate', opts[:invoice_date])
      end

      def terms_of_shipment
        element_with_value('TermsOfShipment', opts[:terms_of_shipment])
      end

      def declaration_statement
        element_with_value('DeclarationStatement', opts[:declaration_statement])
      end    

      def reason_for_export
        element_with_value('ReasonForExport', opts[:reason_for_export])
      end

      def currency_code
        element_with_value('CurrencyCode', opts[:currency_code])
      end

      def freight_charge
        multi_valued('FreightCharges', MonetaryValue: opts[:freight_charge])
      end

      def discount
        multi_valued('Discount', MonetaryValue: opts[:discount])
      end

      def product_details
        opts[:products].map do |product_opts|
          product_container(product_opts)
        end
      end

      def product_container(opts = {})
        InternationalInvoiceProductBuilder.new('Product', opts).to_xml
      end

      # Returns an XML representation of the current object
      #
      # @return [Ox::Element] XML representation of the current object
      def to_xml
        Element.new(name).tap do |international_form|
          international_form << form_type
          international_form << invoice_number if opts[:invoice_number]
          international_form << invoice_date
          international_form << terms_of_shipment if opts[:terms_of_shipment]
          international_form << declaration_statement if opts[:declaration_statement]
          international_form << reason_for_export
          international_form << currency_code
          international_form << freight_charge
          international_form << discount

          product_details.each do |product_detail|
            international_form << product_detail
          end
        end
      end
    end
  end
end
