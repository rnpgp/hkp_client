require_relative "spec_helper"

RSpec.describe HkpClient do
  it "has a version number" do
    expect(HkpClient::VERSION).not_to be nil
  end

  describe "#get", :vcr do
    subject { HkpClient.method(:get) }
    let(:query_string) { "linus@example.com" }

    it "performs a get request" do
      expect(HkpClient).to receive(:query).
        with(hash_including(op: "get", search: query_string)).
        and_call_original
      subject.call query_string
    end

    it "allows for 'exact' queries" do
      expect(HkpClient).to receive(:query).
        with(hash_including(op: "get", search: query_string, exact: "on")).
        and_call_original
      subject.call query_string, exact: true
    end

    it "returns a string with armored PGP key when found" do
      retval = subject.call "linus@example.com"
      expect(retval).to be_a(String)
      expect(retval).to start_with("-----BEGIN PGP PUBLIC KEY BLOCK-----")
      expect(retval.strip).to end_with("-----END PGP PUBLIC KEY BLOCK-----")
    end

    it "returns nil when not found" do
      retval = subject.call "sdfasdfasdfadsfesdfdgfjh12334kasdsdfs6@example.com"
      expect(retval).to be_nil
    end
  end
end
