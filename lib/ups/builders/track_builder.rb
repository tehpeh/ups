require 'ox'

module UPS
  module Builders
    # The {TrackBuilder} class builds UPS XML Track Objects.
    #
    # @author Stephan van Diepen
    # @since 0.17.1
    class TrackBuilder < BuilderBase
      include Ox

      # Initializes a new {TrackBuilder} object
      #
      def initialize
        super 'TrackRequest'
      end

      # Adds an TrackingNumber to the XML document being built
      # according to user inputs
      #
      # @return [void]
      def add_tracking_number(number)
        root << element_with_value('TrackingNumber', number)
      end
    end
  end
end
