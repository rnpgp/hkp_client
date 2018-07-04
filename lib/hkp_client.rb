# frozen_string_literal: true

require "hkp_client/version"
require "hkp_client/uri_schemes"

require "faraday"
require "uri"

module HkpClient
  DEFAULT_KEYSERVER = URI("hkp://pool.sks-keyservers.net").freeze

  class Error < StandardError; end

  PUB_ENTRY_FIELDS =
    %i[key_id algorithm key_length creation_date expiration_date flags].freeze

  UID_ENTRY_FIELDS =
    %i[name creation_date expiration_date flags].freeze

  module_function

  # Fetches a keyring containing open PGP keys from keyserver, and returns it
  # as an ASCII-armoured string.
  #
  # @param string [String] a search string
  # @param keyserver (see #query)
  # @return [String] keyring
  # @return [nil] if key could not be found
  # @raise [HkpClient::Error] if server responds with different HTTP code than
  #   200 or 404
  # @raise any other exceptions caused by networking problems
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

  # Performs a search query on keyserver, and returns a list of key
  # descriptions (see README for details).
  #
  # @param string (see #get)
  # @param exact [Boolean] whether to perform an "exact" search
  # @param keyserver (see #query)
  # @return [Array<Hash>] list of found keys, possibly empty
  # @raise [HkpClient::Error] if server responds with different HTTP code than
  #   200 or 404
  # @raise any other exceptions caused by networking problems
  def search(string, keyserver: DEFAULT_KEYSERVER, exact: false)
    resp = query(
      keyserver: keyserver,
      op: "index",
      search: string,
      options: "mr",
      exact: (exact ? "on" : "off"),
    )

    resp_body = Util.response_body_or_error_or_nil(resp) || ""
    Util.parse_search_response_entries(resp_body)
  end

  # Makes a query to keyserver.  Any surplus keyword arguments will be used
  # as request parameters.
  #
  # @param keyserver [String] a keyserver to query
  # @return [Faraday::Response]
  # @raise any exceptions caused by networking problems
  def query(keyserver: DEFAULT_KEYSERVER, **query_args)
    uri = (URI === keyserver ? keyserver.dup : URI.parse(keyserver))
    use_ssl = %w[https hkps].include?(uri.scheme)
    Faraday.new(url: uri, ssl: use_ssl).get("/pks/lookup", query_args)
  end

  # Utilities to be considered as kinda private API.
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

    # rubocop:disable Metrics/MethodLength

    def parse_search_response_entries(src_string)
      src_string.each_line.reduce([]) do |found_keys, line|
        case line
        when /\Apub:/
          key = response_line_to_hash(line, PUB_ENTRY_FIELDS)
          key[:uids] = []
          found_keys << key
        when /\Auid:/
          uid = response_line_to_hash(line, UID_ENTRY_FIELDS)
          uid[:name] = CGI.unescape(uid[:name])
          found_keys.last[:uids] << uid
        end
        found_keys
      end
    end
    # rubocop:enable Metrics/MethodLength

    def response_line_to_hash(line, field_names)
      _line_type, *fields = line.strip.split(":")
      fields.push(nil) while fields.length < field_names.length
      [field_names, fields].transpose.to_h
    end
  end
end
