require "uri"

module URI
  class HKP < HTTP
    DEFAULT_PORT = 11371
  end

  class HKPS < HTTPS
    DEFAULT_PORT = 443
  end
end

URI.scheme_list["HKP".freeze] ||= URI::HKP
URI.scheme_list["HKPS".freeze] ||= URI::HKPS
