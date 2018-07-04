# frozen_string_literal: true

require "hkp_client/version"
require "hkp_client/uri_schemes"

require "faraday"
require "uri"

module HkpClient
  DEFAULT_KEYSERVER = URI("hkp://pool.sks-keyservers.net").freeze

  class Error < StandardError; end

  module_function

  def get(string, keyserver: DEFAULT_KEYSERVER, exact: false)
    resp = query(
      keyserver: keyserver,
      op: "get",
      search: string,
      options: "mr",
      exact: (exact ? "on" : "off"),
    )

    Util.response_body_or_error_or_nil(resp)
  end

  def query(keyserver: DEFAULT_KEYSERVER, **query_args)
    uri = (URI === keyserver ? keyserver.dup : URI.parse(keyserver))
    use_ssl = %w[https hkps].include?(uri.scheme)
    Faraday.new(url: uri, ssl: use_ssl).get("/pks/lookup", query_args)
  end

  module Util
    module_function

    def response_body_or_error_or_nil(resp)
      if resp.success?
        resp.body
      elsif resp.status == 404
        nil
      else
        raise Error, "Server responded with #{resp.status}"
      end
    end
  end
end
