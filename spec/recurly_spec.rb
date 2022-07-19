require 'spec_helper'

describe RecurlyV2 do
  describe "api key" do

    it "must be assignable" do
      RecurlyV2.api_key = 'new_key'
      RecurlyV2.api_key.must_equal 'new_key'
    end

    it "must raise an exception when not set" do
      if RecurlyV2.instance_variable_defined? :@api_key
        RecurlyV2.send :remove_instance_variable, :@api_key
      end
      proc { RecurlyV2.api_key }.must_raise ConfigurationError
    end

    it "must raise an exception when set to nil" do
      RecurlyV2.api_key = nil
      proc { RecurlyV2.api_key }.must_raise ConfigurationError
    end

    it "must use defaults set if not sent in new thread" do
      RecurlyV2.api_key = 'old_key'
      RecurlyV2.subdomain = 'olddomain'
      RecurlyV2.default_currency = 'US'
      Thread.new {
        RecurlyV2.api_key.must_equal 'old_key'
        RecurlyV2.subdomain.must_equal 'olddomain'
        RecurlyV2.default_currency.must_equal 'US'
      }
    end

    it "must use new values set in thread context" do
      RecurlyV2.api_key = 'old_key'
      RecurlyV2.subdomain = 'olddomain'
      RecurlyV2.default_currency = 'US'
      Thread.new {
          RecurlyV2.config(api_key: "test", subdomain: "testsub", default_currency: "IR")
          RecurlyV2.api_key.must_equal 'test'
          RecurlyV2.subdomain.must_equal 'testsub'
          RecurlyV2.default_currency.must_equal 'IR'
      }
      RecurlyV2.api_key.must_equal 'old_key'
      RecurlyV2.subdomain.must_equal 'olddomain'
      RecurlyV2.default_currency.must_equal 'US'
    end
  end
end
