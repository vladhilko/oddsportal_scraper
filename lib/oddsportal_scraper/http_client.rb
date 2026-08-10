# frozen_string_literal: true

require 'net/http'
require 'uri'

module OddsportalScraper
  class HttpClient
    Response = Struct.new(:status, :headers, :body, keyword_init: true)

    RETRYABLE_ERRORS = [
      Net::OpenTimeout,
      Net::ReadTimeout,
      Errno::ECONNRESET,
      Errno::EPIPE,
      IOError
    ].freeze
    RETRYABLE_STATUSES = [500, 502, 503, 504].freeze

    def initialize(open_timeout: 10, read_timeout: 30, max_retries: 2, retry_delay: 0.25, user_agent: nil)
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @max_retries = max_retries
      @retry_delay = retry_delay
      @user_agent = user_agent || 'oddsportal_scraper/2.0 (+https://github.com/vladhilko/oddsportal_scraper)'
    end

    # The retry/redirect state machine is intentionally kept together so each
    # request follows the same failure policy.
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def get(url)
      uri = parse_uri(url)
      redirects = 0
      attempts = 0

      loop do
        response = request(uri)

        if response.is_a?(Net::HTTPRedirection)
          redirects += 1
          raise transport_error('Too many redirects', url: uri, status: response.code.to_i) if redirects > 4

          location = response['location']
          if location.to_s.empty?
            raise transport_error('Redirect response did not include a location', url: uri,
                                                                                  status: response.code.to_i)
          end

          uri = redirect_uri(uri, location)
          next
        end

        status = response.code.to_i
        if RETRYABLE_STATUSES.include?(status) && attempts < @max_retries
          attempts += 1
          sleep(@retry_delay * attempts) if @retry_delay.positive?
          next
        end

        if response.is_a?(Net::HTTPSuccess)
          return Response.new(status:, headers: response.each_header.to_h, body: response.body.to_s)
        end

        raise transport_error("OddsPortal returned HTTP #{status}", url: uri, status:)
      rescue *RETRYABLE_ERRORS => e
        if attempts >= @max_retries
          raise transport_error("OddsPortal request failed after #{attempts + 1} attempt(s): #{e.message}", url: uri,
                                                                                                            cause: e)
        end

        attempts += 1
        sleep(@retry_delay * attempts) if @retry_delay.positive?
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def parse_uri(url)
      uri = URI.parse(url.to_s)
      return uri if %w[http https].include?(uri.scheme) && uri.host

      raise transport_error('OddsPortal request URL must use HTTP or HTTPS', url: url)
    rescue URI::InvalidURIError => e
      raise transport_error("OddsPortal request URL is invalid: #{e.message}", url: url, cause: e)
    end

    def redirect_uri(uri, location)
      URI.join(uri.to_s, location)
    rescue URI::InvalidURIError => e
      raise transport_error("OddsPortal redirect URL is invalid: #{e.message}", url: uri, cause: e)
    end

    def request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout
      http.write_timeout = @read_timeout if http.respond_to?(:write_timeout=)

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = 'text/html,application/json;q=0.9,*/*;q=0.8'
      request['Accept-Encoding'] = 'identity'
      request['User-Agent'] = @user_agent
      request['Referer'] = 'https://www.oddsportal.com/'
      http.request(request)
    end

    def transport_error(message, url:, status: nil, cause: nil)
      error = TransportError.new(message, url: url.to_s, status:)
      error.set_backtrace(cause.backtrace) if cause
      error
    end
  end
end
