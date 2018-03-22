require 'spec_helper'

class UPS::Builders::TestVoidShipmentBuilder < Minitest::Test
  include SchemaPath
  include ShippingOptions

  def setup
    @ship_confirm_builder = UPS::Builders::VoidShipmentBuilder.new do |builder|
      builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
      builder.add_shipment_identification_number('1Z12345E0390817264')
    end
  end

  def test_validates_against_xsd
    assert_passes_validation schema_path('ShipConfirmRequest.xsd'), @ship_confirm_builder.to_xml
  end
end
