require 'uri'
require 'ox'

module UPS
  module Parsers
    class BaseParser
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def success?
        status_code == '1'
      end

      def status_code
        root_response[:Response][:ResponseStatusCode]
      end

      def status_description
        root_response[:Response][:ResponseStatusDescription]
      end

      def error_description
        build_error_description(error_response)
      end

      def parsed_response
        @parsed_response ||= Ox.load(response, mode: :hash)
      end

      private

      def normalize_response_into_array(response_node)
        [response_node].flatten
      end

      def build_error_description(errors_node)
        return unless errors_node
        return errors_node.last[:ErrorDescription] if errors_node.is_a?(Array)

        errors_node[:ErrorDescription]
      end

      def error_response
        root_response[:Response][:Error]
      end
    end
  end
end
