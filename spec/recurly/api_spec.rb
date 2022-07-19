require 'spec_helper'

describe API do
  describe "HTTP errors" do
    it "must raise exceptions" do
      API::ERRORS.each_pair do |code, exception|
        stub_api_request(:any, 'endpoint') { "HTTP/1.1 #{code}\n" }
        proc { API.get 'endpoint' }.must_raise exception
      end
    end

    it "must properly handle cloudflare 502 errors" do
      stub_api_request(:any, 'endpoint', 'cloudflare_error')
      proc { API.get 'endpoint' }.must_raise RecurlyV2::API::GatewayError
    end
  end
end
