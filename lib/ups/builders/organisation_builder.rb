require 'ox'

module UPS
  module Builders
    # The {OrganisationBuilder} class builds UPS XML Organization Objects.
    #
    # @author Paul Trippett
    # @since 0.1.0
    # @attr [String] name The Containing XML Element Name
    # @attr [Hash] opts The Organization and Address Parts
    class OrganisationBuilder < BuilderBase
      include Ox

      attr_accessor :name, :opts

      # Initializes a new {AddressBuilder} object
      #
      # @param [Hash] opts The Organization and Address Parts
      # @option opts [String] :company_name Company Name
      # @option opts [String] :phone_number Phone Number
      # @option opts [String] :address_line_1 Address Line 1
      # @option opts [String] :city City
      # @option opts [String] :state State
      # @option opts [String] :postal_code Zip or Postal Code
      # @option opts [String] :country Country
      def initialize(name, opts = {})
        self.name = name
        self.opts = opts
        self.opts[:skip_ireland_state_validation] = (name == 'SoldTo')
      end

      # Returns an XML representation of company_name
      #
      # @return [Ox::Element] XML representation of company_name
      def company_name
        element_with_value('CompanyName', opts[:company_name][0..34])
      end

      # Returns an XML representation of phone_number
      #
      # @return [Ox::Element] XML representation of phone_number
      def phone_number
        element_with_value('PhoneNumber', opts[:phone_number][0..14])
      end

      # Returns an XML representation of AttentionName for which we use company
      # name
      #
      # @return [Ox::Element] XML representation of company_name part
      def attention_name
        element_with_value('AttentionName', opts[:attention_name][0..34])
      end

      # Returns an XML representation of sender_vat_number of the company
      #
      # @return [Ox::Element] XML representation of sender_vat_number
      def tax_identification_number
        element_with_value('TaxIdentificationNumber', opts[:sender_vat_number] || '')
      end

      # Returns an XML representation of the email address of the company
      #
      # @return [Ox::Element] XML representation of email address
      def email_address
        element_with_value('EMailAddress', opts[:email_address].to_s[0..50])
      end

      # Returns an XML representation of address
      #
      # @return [Ox::Element] An instance of {AddressBuilder} containing the
      #   address
      def address
        AddressBuilder.new(opts).to_xml
      end

      # Returns an XML representation of vendor info (ioss number and more) of the company
      #
      # @return [Ox::Element] XML representation of sender_ioss_number
      def vendor_info
        ioss_vendor_collect_id = '0356'

        Element.new('VendorInfo').tap do |vendor_info|
          vendor_info << element_with_value('VendorCollectIDNumber', opts[:sender_ioss_number] || '')
          vendor_info << element_with_value('VendorCollectIDTypeCode', ioss_vendor_collect_id)
          vendor_info << element_with_value('ConsigneeType', '02')
        end
      end

      # Returns an XML representation of a UPS Organization
      #
      # @return [Ox::Element] XML representation of the current object
      def to_xml
        Element.new(name).tap do |org|
          org << company_name
          org << phone_number
          org << attention_name
          org << address
          org << tax_identification_number
          org << email_address
          org << vendor_info unless opts[:sender_ioss_number].to_s.empty?
        end
      end
    end
  end
end
