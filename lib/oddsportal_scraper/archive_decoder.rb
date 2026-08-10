# frozen_string_literal: true

require 'base64'
require 'json'
require 'openssl'
require 'stringio'
require 'zlib'

module OddsportalScraper
  class ArchiveDecoder
    PASSPHRASE = Base64.decode64('Sio4c1EhcCQ3YURfZlIyeVdAZ0huKjNiVnAjc0FkTGRfaw==')
    SALT = Base64.decode64('NWI5YThmMmMzZTZkMWE0YjdjOGU5ZDBmMWEyYjNjNGQ=')
    ITERATIONS = 1_000
    KEY_LENGTH = 32

    def self.decode(body)
      new.decode(body)
    end

    def decode(body)
      outer = Base64.strict_decode64(body.to_s.strip.delete("\r\n\t "))
      ciphertext_base64, iv_hex = outer.split(':', 2)
      if ciphertext_base64.to_s.empty? || iv_hex.to_s.empty?
        raise ProtocolError,
              'OddsPortal archive response did not contain an IV'
      end

      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.key = encryption_key
      cipher.iv = [iv_hex].pack('H*')

      compressed = cipher.update(Base64.strict_decode64(ciphertext_base64)) + cipher.final
      JSON.parse(Zlib::GzipReader.new(StringIO.new(compressed)).read)
    rescue ArgumentError, OpenSSL::Cipher::CipherError, JSON::ParserError, Zlib::Error => e
      raise ProtocolError, "Could not decode OddsPortal archive response: #{e.message}"
    end

    private

    def encryption_key
      OpenSSL::PKCS5.pbkdf2_hmac(PASSPHRASE, SALT, ITERATIONS, KEY_LENGTH, 'sha256')
    end
  end
end
