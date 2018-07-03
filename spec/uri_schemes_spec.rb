require_relative "spec_helper"

RSpec.describe URI::HKP, "HKP URI scheme" do
  let(:example_uri_string) { "hkp://pool.sks-keyservers.example.test" }
  let(:example_uri) { URI.parse(example_uri_string) }

  it "is a specific case of HTTP protocol" do
    expect(described_class.superclass).to be(URI::HTTP)
    expect(example_uri).to be_kind_of(URI::HTTP)
    expect(example_uri).not_to be_instance_of(URI::HTTP)
  end

  it "defines 11371 as a default port" do
    expect(example_uri.port).to eq(11371)
  end
end

RSpec.describe URI::HKPS, "HKPS URI scheme" do
  let(:example_uri_string) { "hkps://pool.sks-keyservers.example.test" }
  let(:example_uri) { URI.parse(example_uri_string) }

  it "is a specific case of HTTPS protocol" do
    expect(described_class.superclass).to be(URI::HTTPS)
    expect(example_uri).to be_kind_of(URI::HTTPS)
    expect(example_uri).not_to be_instance_of(URI::HTTPS)
  end

  it "defines 443 as a default port" do
    expect(example_uri.port).to eq(443)
  end
end
