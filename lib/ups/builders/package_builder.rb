require 'ox'

module UPS
  module Builders
    class PackageBuilder < BuilderBase
      include Ox

      attr_accessor :name, :opts

      def initialize(name, opts = {})
        self.name = name
        self.opts = opts
      end

      def packaging_type(packaging_options_hash)
        code_description 'PackagingType', packaging_options_hash[:code], packaging_options_hash[:description]
      end

      def reference_number
        Element.new('ReferenceNumber').tap do |org|
          org << element_with_value('Code', opts[:reference_number][:type]) if opts[:reference_number][:type]
          org << element_with_value('Value', opts[:reference_number][:value])
        end
      end

      def order_number
        Element.new('ReferenceNumber').tap do |org|
          org << element_with_value('Code', opts[:order_number][:type]) if opts[:order_number][:type]
          org << element_with_value('Value', opts[:order_number][:value])
        end
      end

      def description
        element_with_value('Description', 'Rate')
      end

      def package_weight(weight, unit)
        Element.new('PackageWeight').tap do |org|
          org << unit_of_measurement(unit)
          org << element_with_value('Weight', weight)
        end
      end

      def customer_supplied_packaging
        { code: '02', description: 'Customer Supplied Package' }
      end

      def package_dimensions(dimensions)
        Element.new('Dimensions').tap do |org|
          org << unit_of_measurement(dimensions[:unit])
          org << element_with_value('Length', dimensions[:length].to_s[0..8])
          org << element_with_value('Width', dimensions[:width].to_s[0..8])
          org << element_with_value('Height', dimensions[:height].to_s[0..8])
        end
      end

      def to_xml
        Element.new(name).tap do |product|
          product << reference_number if opts[:reference_number]
          product << order_number if opts[:order_number]
          product << packaging_type(opts[:packaging_type] || customer_supplied_packaging)
          product << description
          product << package_weight(opts[:weight], opts[:unit])
          product << package_dimensions(opts[:dimensions]) if opts[:dimensions]
        end
      end
    end
  end
end
