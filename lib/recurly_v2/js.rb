module RecurlyV2
  module JS
    class << self
      # @return [String] A public key for RecurlyV2.js.
      # @raise [ConfigurationError] No public key has been set.
      def public_key
        defined? @public_key and @public_key or raise(
          ConfigurationError, "public_key not configured"
        )
      end
      attr_writer :public_key
    end
  end
end
