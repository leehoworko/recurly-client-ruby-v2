require 'cgi'
require 'net/https'

module RecurlyV2
  class API
    module Net
      module HTTPAdapter
        # A hash of Net::HTTP settings configured before the request.
        #
        # @return [Hash]
        def net_http
          @net_http ||= {}
        end

        # Used to store any Net::HTTP settings.
        #
        # @example
        #   RecurlyV2::API.net_http = {
        #     :verify_mode => OpenSSL::SSL::VERIFY_PEER,
        #     :ca_path     => "/etc/ssl/certs",
        #     :ca_file     => "/opt/local/share/curl/curl-ca-bundle.crt"
        #   }
        attr_writer :net_http

        private

        METHODS = {
          :head   => ::Net::HTTP::Head,
          :get    => ::Net::HTTP::Get,
          :post   => ::Net::HTTP::Post,
          :put    => ::Net::HTTP::Put,
          :delete => ::Net::HTTP::Delete
        }

        def request method, uri, options = {}
          head = headers.dup
          head.update options[:head] if options[:head]
          head.delete_if { |_, value| value.nil? }
          uri = base_uri + uri
          if options[:params] && !options[:params].empty?
            pairs = options[:params].map { |key, value|
              "#{CGI.escape key.to_s}=#{CGI.escape value.to_s}"
            }
            uri += "?#{pairs.join '&'}"
          end
          self.validate_uri!(uri)
          request = METHODS[method].new uri.request_uri, head
          request.basic_auth(*[RecurlyV2.api_key, nil].flatten[0, 2])
          if options[:body]
            request['Content-Type'] = content_type
            request.body = options[:body]
          end
          if options[:etag]
            request['If-None-Match'] = options[:etag]
          end
          if options[:format]
            request['Accept'] = FORMATS[options[:format]]
          end
          if options[:locale]
            request['Accept-Language'] = options[:locale]
          end
          http = ::Net::HTTP.new uri.host, uri.port
          http.use_ssl = uri.scheme == 'https'
          net_http.each_pair { |key, value| http.send "#{key}=", value }

          if RecurlyV2.logger
            RecurlyV2.log :info, "===> %s %s" % [request.method, uri]
            headers = request.to_hash
            headers['authorization'] &&= ['Basic [FILTERED]']
            RecurlyV2.log :debug, headers.inspect
            if request.body && !request.body.empty?
              RecurlyV2.log :debug, XML.filter(request.body)
            end
            start_time = Time.now
          end

          response = http.start { http.request request }
          code = response.code.to_i

          if RecurlyV2.logger
            latency = (Time.now - start_time) * 1_000
            level = case code
              when 200...300 then :info
              when 300...400 then :warn
              when 400...500 then :error
              else                :fatal
            end
            RecurlyV2.log level, "<=== %d %s (%.1fms)" % [
              code,
              response.class.name[9, response.class.name.length].gsub(
                /([a-z])([A-Z])/, '\1 \2'
              ),
              latency
            ]
            RecurlyV2.log :debug, response.to_hash.inspect
            RecurlyV2.log :debug, response.body if response.body
          end

          case code
            when 200...300 then response
            else                raise ERRORS[code].new request, response
          end
        rescue Errno::ECONNREFUSED => e
          raise Error, e.message
        end
      end
    end

    extend Net::HTTPAdapter
  end
end
