require 'spec_helper'
require 'support/shipping_options'

describe UPS::Connection do
  include ShippingOptions

  before do
    Excon.defaults[:mock] = true
  end

  after do
    Excon.stubs.clear
  end

  let(:stub_path) { File.expand_path("../../../stubs", __FILE__) }
  let(:server) { UPS::Connection.new(test_mode: true) }
  let(:supplied_package) { package }

  describe 'if tracking shipment' do
    subject do
      server.track do |track_builder|
        track_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
        track_builder.add_tracking_number '1Z12345E6692804405'
      end
    end

    describe 'successful track response' do
      before do
        Excon.stub(method: :post) do |params|
          case params[:path]
          when UPS::Connection::TRACK_PATH
            { body: File.read("#{stub_path}/track_success.xml"), status: 200 }
          end
        end
      end

      it 'returns the tracking status' do
        expect(subject.to_h).wont_be_empty
        expect(subject.to_h).must_equal(
          status_date: Date.parse('2010-06-10'),
          status_type_description: 'DELIVERED',
          status_type_code: 'D'
        )
      end
    end
  end
end
