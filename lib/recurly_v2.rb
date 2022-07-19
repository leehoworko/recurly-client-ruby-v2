# Recurly is a Ruby client for Recurly's REST API.
module RecurlyV2
  require_relative 'recurly_v2/error'
  require_relative 'recurly_v2/helper'
  require_relative 'recurly_v2/api'
  require_relative 'recurly_v2/resource'
  require_relative 'recurly_v2/shipping_address'
  require_relative 'recurly_v2/billing_info'
  require_relative 'recurly_v2/custom_field'
  require_relative 'recurly_v2/account_acquisition'
  require_relative 'recurly_v2/account'
  require_relative 'recurly_v2/account_balance'
  require_relative 'recurly_v2/add_on'
  require_relative 'recurly_v2/address'
  require_relative 'recurly_v2/tax_detail'
  require_relative 'recurly_v2/tax_type'
  require_relative 'recurly_v2/juris_detail'
  require_relative 'recurly_v2/adjustment'
  require_relative 'recurly_v2/coupon'
  require_relative 'recurly_v2/credit_payment'
  require_relative 'recurly_v2/helper'
  require_relative 'recurly_v2/invoice'
  require_relative 'recurly_v2/invoice_collection'
  require_relative 'recurly_v2/item'
  require_relative 'recurly_v2/js'
  require_relative 'recurly_v2/money'
  require_relative 'recurly_v2/measured_unit'
  require_relative 'recurly_v2/note'
  require_relative 'recurly_v2/plan'
  require_relative 'recurly_v2/redemption'
  require_relative 'recurly_v2/shipping_fee'
  require_relative 'recurly_v2/shipping_method'
  require_relative 'recurly_v2/subscription'
  require_relative 'recurly_v2/subscription_add_on'
  require_relative 'recurly_v2/transaction'
  require_relative 'recurly_v2/usage'
  require_relative 'recurly_v2/version'
  require_relative 'recurly_v2/xml'
  require_relative 'recurly_v2/delivery'
  require_relative 'recurly_v2/gift_card'
  require_relative 'recurly_v2/purchase'
  require_relative 'recurly_v2/webhook'
  require_relative 'recurly_v2/tier'

  @subdomain = nil

  # This exception is raised if Recurly has not been configured.
  class ConfigurationError < Error
  end

  class << self
    # Set a config based on current thread context.
    # Any default set will say in effect unless overwritten in the config_params.
    # Call this method with out any arguments to have it unset the thread context config values.
    # @param config_params - Hash with the following keys: subdomain, api_key, default_currency
    def config(config_params = nil)
      Thread.current[:recurly_config] = config_params
    end

    # @return [String] A subdomain.
    def subdomain
      if Thread.current[:recurly_config] && Thread.current[:recurly_config][:subdomain]
        return Thread.current[:recurly_config][:subdomain]
      end
      @subdomain || 'api'
    end
    attr_writer :subdomain

    # @return [String] An API key.
    # @raise [ConfigurationError] If not configured.
    def api_key
      if Thread.current[:recurly_config] && Thread.current[:recurly_config][:api_key]
        return Thread.current[:recurly_config][:api_key]
      end

      defined? @api_key and @api_key or raise(
        ConfigurationError, "RecurlyV2.api_key not configured"
      )
    end
    attr_writer :api_key

    # @return [String, nil] A default currency.
    def default_currency
      if Thread.current[:recurly_config] &&  Thread.current[:recurly_config][:default_currency]
        return Thread.current[:recurly_config][:default_currency]
      end

      return  @default_currency if defined? @default_currency
      @default_currency = 'USD'
    end
    attr_writer :default_currency

    # @return [JS] The RecurlyV2.js module.
    def js
      JS
    end

    # Assigns a logger to log requests/responses and more.
    # The logger can only be set if the environment variable
    # `RECURLY_INSECURE_DEBUG` equals `true`.
    #
    # @return [Logger, nil]
    # @example
    #   require 'logger'
    #   RecurlyV2.logger = Logger.new STDOUT
    # @example Rails applications automatically log to the Rails log:
    #   RecurlyV2.logger = Rails.logger
    # @example Turn off logging entirely:
    #   RecurlyV2.logger = nil # Or RecurlyV2.logger = Logger.new nil
    attr_accessor :logger

    def logger=(logger)
      if ENV['RECURLY_INSECURE_DEBUG'].to_s.downcase == 'true'
        @logger = logger
        puts <<-MSG
        [WARNING] Recurly logger enabled. The logger has the potential to leak
        PII and should never be used in production environments.
        MSG
      else
        puts <<-MSG
        [WARNING] Recurly logger has been disabled. If you wish to use it,
        only do so in a non-production environment and make sure
        the `RECURLY_INSECURE_DEBUG` environment variable is set to `true`.
        MSG
      end
    end

    # Convenience logging method includes a Logger#progname dynamically.
    # @return [true, nil]
    def log level, message
      logger.send(level, name) { message }
    end

    if RUBY_VERSION <= "1.9.0"
      def const_defined? sym, inherit = false
        raise ArgumentError, "inherit must be false" if inherit
        super sym
      end

      def const_get sym, inherit = false
        raise ArgumentError, "inherit must be false" if inherit
        super sym
      end
    end
  end
end
