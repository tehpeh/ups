require "spec_helper"

describe UPS::Builders::OrganisationBuilder do
  subject { UPS::Builders::OrganisationBuilder.new(builder_name) }

  describe "when the name is 'SoldTo'" do
    let(:builder_name) { 'SoldTo' }

    it "enables option to skip Ireland state validation" do
      subject.opts[:skip_ireland_state_validation].must_equal true
    end
  end

  describe "when the name is anything else" do
    let(:builder_name) { 'Hamburger' }

    it "disables option to skip Ireland state validation" do
      subject.opts[:skip_ireland_state_validation].must_equal false
    end
  end

  describe "#to_xml" do
    let(:ioss_id) { 'IOSS32341313' }
    let(:vat_id) { 'GB800909000' }

    let(:address_hash) do
      {
        address_line_1: 'Googleplex',
        address_line_2: '1600 Amphitheatre Parkway',
        city: 'Mountain View',
        state: 'California',
        postal_code: '94043',
        country: 'US',
      }
    end

    let(:organisation_hash) do
      {
        company_name: 'Company LTD',
        phone_number: '07452444345',
        attention_name: 'John Smith',
        sender_vat_number: vat_id,
        sender_ioss_number: ioss_id,
        email_address: 'john.smith@company.com',
      }
    end

    let(:opts) { organisation_hash.merge(address_hash) }

    subject { Ox.dump UPS::Builders::OrganisationBuilder.new('SoldTo', opts).to_xml }

    it 'populates the xml with the correct elements' do
      subject.must_include '<CompanyName>Company LTD</CompanyName>'
      subject.must_include '<PhoneNumber>07452444345</PhoneNumber>'
      subject.must_include '<AttentionName>John Smith</AttentionName>'
      subject.must_include '<Address>'
      subject.must_include '<TaxIdentificationNumber>GB800909000</TaxIdentificationNumber>'
      subject.must_include '<EMailAddress>john.smith@company.com</EMailAddress>'
      subject.must_include '<VendorCollectIDNumber>IOSS32341313</VendorCollectIDNumber>'
      subject.must_include '<VendorCollectIDTypeCode>0356</VendorCollectIDTypeCode>'
    end

    describe 'when there is no IOSS id' do
      let(:ioss_id) { nil }

      it 'does not send the VendorInfo element at all' do
        subject.wont_include '<VendorInfo>'
        subject.wont_include '<VendorCollectIDNumber>IOSS32341313</VendorCollectIDNumber>'
      end
    end
  end
end
