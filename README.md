[![Gem Version](https://img.shields.io/gem/v/ups-ruby.svg?style=flat-square)](http://badge.fury.io/rb/ups-ruby)

# UPS

UPS Gem for accessing the UPS API from Ruby. Using the gem you can:
  - Return quotes from the UPS API
  - Book shipments
  - Return labels and tracking numbers for a shipment

This gem is currently used in production at [Veeqo](http://www.veeqo.com)

## Installation

    gem install ups-ruby

...or add it to your project's [Gemfile](http://bundler.io/).

## Documentation

Yard documentation can be found at [RubyDoc](http://www.rubydoc.info/github/veeqo/ups-ruby).

## Sample Usage

### Return rates

```ruby
require 'ups'
server = UPS::Connection.new(test_mode: true)
response = server.rates do |rate_builder|
  rate_builder.add_access_request 'API_KEY', 'USERNAME', 'PASSWORD'
  rate_builder.add_shipper company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    address_line_1: '11 Wind Street',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  rate_builder.add_ship_from company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    address_line_1: '11 Wind Street',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  rate_builder.add_ship_to company_name: 'Google Inc.',
    phone_number: '0207 031 3000',
    address_line_1: '1 St Giles High Street',
    city: 'London',
    state: 'England',
    postal_code: 'WC2H 8AG',
    country: 'GB'
  rate_builder.add_package weight: '0.5',
    unit: 'KGS'
end
```

### Create domestic shipment
```ruby
require 'ups-ruby'
server = UPS::Connection.new(test_mode: true)
response = server.ship do |shipment_builder|
  shipment_builder.add_access_request 'API_KEY', 'USERNAME', 'PASSWORD'
  shipment_builder.add_shipper company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    attention_name: 'John Doe',
    address_line_1: '11 Wind Street',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  shipment_builder.add_ship_from company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    address_line_1: '11 Wind Street',
    attention_name: 'John Doe',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  shipment_builder.add_ship_to company_name: 'Google Inc.',
    phone_number: '0207 031 3000',
    address_line_1: '1 St Giles High Street',
    attention_name: 'John Doe',
    city: 'London',
    state: 'England',
    postal_code: 'WC2H 8AG',
    country: 'GB'
  shipment_builder.add_package weight: '0.5',
    unit: 'KGS'
  shipment_builder.add_description 'White coffee mug'
  shipment_builder.add_payment_information 'ACCOUNT_NUMBER'
  shipment_builder.add_service '65' # returned in rates response
end
```


```ruby
# Then use...
response.success?
response.label_graphic_image
response.label_html_image
response.label_graphic_extension
response.tracking_number
```

### Create international shipment with customs documentation request
```ruby
require 'ups-ruby'
server = UPS::Connection.new(test_mode: true)
response = server.ship do |shipment_builder|
  shipment_builder.add_access_request 'API_KEY', 'USERNAME', 'PASSWORD'
  shipment_builder.add_shipper company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    attention_name: 'John Doe',
    address_line_1: '11 Wind Street',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  shipment_builder.add_ship_from company_name: 'Veeqo Limited',
    phone_number: '01792 123456',
    address_line_1: '11 Wind Street',
    attention_name: 'John Doe',
    city: 'Swansea',
    state: 'Wales',
    postal_code: 'SA1 1DA',
    country: 'GB',
    shipper_number: 'ACCOUNT_NUMBER'
  shipment_builder.add_ship_to company_name: 'Google Inc.',
    phone_number: '0207 031 3000',
    address_line_1: '389 Townsend Street',
    attention_name: 'John Doe',
    address_line_2: 'Apt 21',
    city: 'San Francisco',
    state: 'CA',
    postal_code: '94107',
    country: 'US'
  shipment_builder.add_sold_to company_name: 'Google Inc.',
    phone_number: '0207 031 3000',
    address_line_1: '389 Townsend Street',
    attention_name: 'John Doe',
    address_line_2: 'Apt 21',
    city: 'San Francisco',
    state: 'CA',
    postal_code: '94107',
    country: 'US'
  shipment_builder.add_package weight: '0.5',
    unit: 'KGS'
  shipment_builder.add_description 'White coffee mug'
  shipment_builder.add_payment_information 'ACCOUNT_NUMBER'
  shipment_builder.add_service '65' # returned in rates response
  shipment_builder.add_international_invoice invoice_number: '#P-1234',
    invoice_date: '20170816',
    reason_for_export: 'SALE',
    currency_code: 'USD',
    products: [
      {
        description: 'White coffee mug',
        number: '1',
        value: '14.02',
        dimensions_unit: 'CM',
        part_number: 'MUG-01-WHITE',
        commodity_code: '123488',
        origin_country_code: 'US'
      },
      {
        description: 'Red coffee mug',
        number: '1',
        value: '14.05',
        dimensions_unit: 'CM',
        part_number: 'MUG-01-RED',
        commodity_code: '567876',
        origin_country_code: 'US'
      }
    ]
end
```


```ruby
# Then use...
response.success?
response.form_graphic_image
response.form_graphic_extension
```

## Running the tests

After installing dependencies with `bundle install`, you can run the unit tests using `rake`.

## Contributers

Thanks to the following contributers to this project.

  - [CJ](https://github.com/chirag7jain) - Method to generate labels in available other formats [EPL, ZPL], Constant for packaging type.
