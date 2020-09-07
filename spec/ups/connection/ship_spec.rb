require 'spec_helper'
require 'tempfile'
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
  let(:ship_accept_stub_file) { 'ship_accept_success' }

  describe 'if requesting a shipment' do
    describe 'single package shipment' do
      before do
        Excon.stub(method: :post) do |params|
          case params[:path]
          when UPS::Connection::SHIP_CONFIRM_PATH
            {
              body: File.read("#{stub_path}/ship_confirm_success.xml"), status: 200
            }
          when UPS::Connection::SHIP_ACCEPT_PATH
            {
              body: File.read("#{stub_path}/#{ship_accept_stub_file}.xml"), status: 200
            }
          end
        end
      end

      subject do
        server.ship do |shipment_builder|
          shipment_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
          shipment_builder.add_shipper shipper
          shipment_builder.add_ship_from shipper
          shipment_builder.add_ship_to ship_to
          shipment_builder.add_package package
          shipment_builder.add_payment_information ENV['UPS_ACCOUNT_NUMBER']
          shipment_builder.add_service '07'
        end
      end

      it 'does what ever it takes to get that shipment shipped!' do
        subject.wont_equal false
        subject.success?.must_equal true
      end

      it 'returns the packages data' do
        subject.packages.must_be_kind_of Array
        subject.packages.size.must_equal 1
      end

      it 'returns the label data' do
        subject.label_graphic_image.must_be_kind_of File
        subject.label_graphic_image.path.end_with?('.gif').must_equal true
        subject.label_graphic_extension.must_equal '.gif'

        subject.graphic_image.must_be_kind_of File
        subject.graphic_image.path.end_with?('.gif').must_equal true
        subject.graphic_extension.must_equal '.gif'

        subject.html_image.must_be_kind_of File
        subject.html_image.path.end_with?('.gif').must_equal true

        subject.label_html_image.must_be_kind_of File
        subject.label_html_image.path.end_with?('.gif').must_equal true
      end

      it 'should return the requested customs form data' do
        subject.form_graphic_image.must_be_kind_of File
        subject.form_graphic_image.path.end_with?('.pdf').must_equal true
        subject.form_graphic_extension.must_equal '.pdf'
      end

      it 'should return the tracking number' do
        subject.tracking_number.must_equal '1Z2220060292353829'
      end

      describe 'total shipment cost' do
        describe 'with negotiated rates' do
          it 'returns the total shipment cost' do
            subject.total_charge.must_equal 115.14
            subject.currency_code.must_equal 'USD'
          end
        end 

        describe 'without negotiated rates' do
          let(:ship_accept_stub_file) { 'ship_accept_success_without_negotiated_price' }

          it 'returns the total shipment cost' do
            subject.total_charge.must_equal 118.48
            subject.currency_code.must_equal 'USD'
          end
        end
      end
    end

    describe 'when packaging type is specified' do
      before do
        Excon.stub(method: :post) do |params|
          case params[:path]
          when UPS::Connection::SHIP_CONFIRM_PATH
            {
              body: File.read("#{stub_path}/ship_confirm_success_with_packaging_type.xml"), status: 200
            }
          when UPS::Connection::SHIP_ACCEPT_PATH
            {
              body: File.read("#{stub_path}/ship_accept_success_with_packaging_type.xml"), status: 200
            }
          end
        end
      end

      subject do
        server.ship do |shipment_builder|
          shipment_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
          shipment_builder.add_shipper shipper
          shipment_builder.add_ship_from shipper
          shipment_builder.add_ship_to ship_to
          shipment_builder.add_package package_with_carrier_packaging_and_dimensions
          shipment_builder.add_payment_information ENV['UPS_ACCOUNT_NUMBER']
          shipment_builder.add_service '07'
        end
      end

      let(:supplied_package) { package_with_carrier_packaging }

      it 'should return the tracking number' do
        subject.tracking_number.must_equal '1Z2R466A6790676189'
      end
    end

    describe 'multi package shipment' do
      before do
        Excon.stub(method: :post) do |params|
          case params[:path]
          when UPS::Connection::SHIP_CONFIRM_PATH
            {
              body: File.read("#{stub_path}/multi_package/ship_confirm_success.xml"), status: 200
            }
          when UPS::Connection::SHIP_ACCEPT_PATH
            {
              body: File.read("#{stub_path}/multi_package/ship_accept_success.xml"), status: 200
            }
          end
        end
      end

      let(:first_package) { subject.packages[0] }
      let(:second_package) { subject.packages[1] }

      subject do
        server.ship do |shipment_builder|
          shipment_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
          shipment_builder.add_shipper shipper
          shipment_builder.add_ship_from shipper
          shipment_builder.add_ship_to ship_to
          shipment_builder.add_package package
          shipment_builder.add_package large_package
          shipment_builder.add_payment_information ENV['UPS_ACCOUNT_NUMBER']
          shipment_builder.add_service '07'
        end
      end

      describe 'legacy methods for first package' do
        it 'returns the label data for the first package' do
          subject.label_graphic_image.must_be_kind_of File
          subject.label_graphic_image.path.end_with?('.gif').must_equal true
          subject.label_graphic_extension.must_equal '.gif'

          subject.graphic_image.must_be_kind_of File
          subject.graphic_image.path.end_with?('.gif').must_equal true
          subject.graphic_extension.must_equal '.gif'

          subject.html_image.must_be_kind_of File
          subject.html_image.path.end_with?('.gif').must_equal true

          subject.label_html_image.must_be_kind_of File
          subject.label_html_image.path.end_with?('.gif').must_equal true
        end

        it 'returns the tracking number of the first package' do
          subject.tracking_number.must_equal '1Z2R466A6894635437'
        end
      end

      it 'returns the packages data' do
        subject.packages.must_be_kind_of Array
        subject.packages.size.must_equal 2
      end

      describe 'data per package' do
        describe 'package #1' do
          it 'returns the correct label data' do
            first_package.label_graphic_image.must_be_kind_of File
            first_package.label_graphic_image.path.end_with?('.gif').must_equal true
            first_package.label_html_image.must_be_kind_of File
            first_package.label_html_image.path.end_with?('.gif').must_equal true
            first_package.label_graphic_extension.must_equal '.gif'
          end

          it 'returns the correct tracking number' do
            first_package.tracking_number.must_equal '1Z2R466A6894635437'
          end
        end

        describe 'package #2' do
          it 'returns the correct label data' do
            second_package.label_graphic_image.must_be_kind_of File
            second_package.label_graphic_image.path.end_with?('.gif').must_equal true
            second_package.label_html_image.must_be_kind_of File
            second_package.label_html_image.path.end_with?('.gif').must_equal true
            second_package.label_graphic_extension.must_equal '.gif'
          end

          it 'returns the correct tracking_number' do
            second_package.tracking_number.must_equal '1Z2R466A6893005048'
          end
        end
      end
    end
  end

  describe "ups returns an error during ship confirm" do
    before do
      Excon.stub({:method => :post}) do |params|
        case params[:path]
        when UPS::Connection::SHIP_CONFIRM_PATH
          {body: File.read("#{stub_path}/ship_confirm_failure.xml"), status: 200}
        end
      end
    end

    subject do
      server.ship do |shipment_builder|
        shipment_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
        shipment_builder.add_shipper shipper
        shipment_builder.add_ship_from shipper
        shipment_builder.add_ship_to ship_to
        shipment_builder.add_package package
        shipment_builder.add_payment_information ENV['UPS_ACCOUNT_NUMBER']
        shipment_builder.add_service '07'
      end
    end

    it "should return a Parsed response with an error code and error description" do
      subject.wont_equal false
      subject.success?.must_equal false
      subject.error_description.must_equal "Missing or invalid shipper number"
    end
  end

  describe "ups returns an error during ship accept" do
    before do
      Excon.stub({:method => :post}) do |params|
        case params[:path]
        when UPS::Connection::SHIP_CONFIRM_PATH
          {body: File.read("#{stub_path}/ship_confirm_success.xml"), status: 200}
        when UPS::Connection::SHIP_ACCEPT_PATH
          {body: File.read("#{stub_path}/ship_accept_failure.xml"), status: 200}
        end
      end
    end

    subject do
      server.ship do |shipment_builder|
        shipment_builder.add_access_request ENV['UPS_LICENSE_NUMBER'], ENV['UPS_USER_ID'], ENV['UPS_PASSWORD']
        shipment_builder.add_shipper shipper
        shipment_builder.add_ship_from shipper
        shipment_builder.add_ship_to ship_to
        shipment_builder.add_package package
        shipment_builder.add_payment_information ENV['UPS_ACCOUNT_NUMBER']
        shipment_builder.add_service '07'
      end
    end

    it "should return a Parsed response with an error code and error description" do
      subject.wont_equal false
      subject.success?.must_equal false
      subject.error_description.must_equal "Missing or invalid shipper number"
    end
  end
end
