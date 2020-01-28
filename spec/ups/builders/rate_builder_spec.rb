require 'spec_helper'

class UPS::Builders::TestRateBuilder < Minitest::Test
  include SchemaPath
  include ShippingOptions

  def setup
    @rate_builder = UPS::Builders::RateBuilder.new do |builder|
      builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
      builder.add_shipper shipper
      builder.add_ship_to ship_to
      builder.add_ship_from shipper
      builder.add_package package
      builder.add_insurance_charge '5.00'
      builder.add_shipment_delivery_confirmation '2'
      builder.add_shipment_direct_delivery_only
    end
  end

  def test_validates_against_xsd
    assert_passes_validation schema_path('RateRequest.xsd'), @rate_builder.to_xml
  end
end
