# This file is automatically created by Recurly's OpenAPI generation process
# and thus any edits you make by hand will be lost. If you wish to make a
# change to this file, please create a Github issue explaining the changes you
# need and we will usher them to the appropriate places.
module Recurly
  module Requests
    class Tier < Request

      # @!attribute currencies
      #   @return [Array[TierPricing]] Tier pricing
      define_attribute :currencies, Array, { :item_type => :TierPricing }

      # @!attribute ending_quantity
      #   @return [Integer] Ending quantity for the tier.  This represents a unit amount for unit-priced add ons.
      define_attribute :ending_quantity, Integer
    end
  end
end
