# frozen_string_literal: true

module OddsportalScraper
  class Error < StandardError; end

  class TransportError < Error
    attr_reader :url, :status

    def initialize(message, url: nil, status: nil)
      @url = url
      @status = status
      super(message)
    end

    def not_found?
      [404, 410].include?(status)
    end
  end

  class ProtocolError < Error; end

  class BrowserUnavailableError < Error; end
end
