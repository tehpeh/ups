require 'uri'
require 'ox'

module UPS
  module Parsers
    class TrackParser < BaseParser
      def initialize(response)
        # Unescape double/triple quoted first line: "<?xml version=\\\"1.0\\\"?>\\n<TrackResponse>\n"
        super(response.gsub(/\\"/, '"').gsub(/\\n/, "\n"))
      end

      def to_h
        {
          status_date: status_date,
          status_type_description: status_type_description,
          status_type_code: status_type_code
        }
      end

      def status_date
        Date.parse(latest_activity[:Date])
      end

      def status_type_description
        status_type[:Description]
      end

      def status_type_code
        status_type[:Code]
      end

      private

      def status_type
        latest_activity[:Status][:StatusType]
      end

      def latest_activity
        activities.sort_by {|a| [a[:GMTDate], a[:GMTTime]] }.last
      end

      def activities
        normalize_response_into_array(root_response[:Shipment][:Package][:Activity])
      end

      def root_response
        parsed_response[:TrackResponse]
      end
    end
  end
end
