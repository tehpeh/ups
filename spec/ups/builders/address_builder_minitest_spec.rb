require 'spec_helper'

class UPS::Builders::TestAddressBuilder < Minitest::Test
  include SchemaPath
  include ShippingOptions

  def setup
    @us_address_builder = UPS::Builders::AddressBuilder.new({country: 'us', state: 'ny', postal_code: '29464'})
    @ie_address_builder = UPS::Builders::AddressBuilder.new({country: 'ie', state: 'galway', postal_code: ''})
    @hk_address_builder = UPS::Builders::AddressBuilder.new({country: 'hk', state: '', postal_code: nil })
  end

  def test_allows_postal_code
    assert_equal(@us_address_builder.postal_code.text, "29464")
  end

  def test_allows_empty_postal_code
    assert_equal(@ie_address_builder.postal_code.text, "")
  end

  def test_allows_nil_postal_code
    assert_equal(@hk_address_builder.postal_code.text, "")
  end

end
