require "spec_helper"

describe CarthageCache::CartfileResolvedFile do

  let(:cartfile_resolved_path) { File.join(FIXTURE_PATH, "Cartfile.resolved") }
  subject(:cartfile_resolved) { CarthageCache::CartfileResolvedFile.new(cartfile_resolved_path) }

  describe "#digest" do

    it "returns a digest of the Cartfile.resolved file content" do
      expect(cartfile_resolved.digest).to eq("a7389856777fbb43a5c5eecf4b30a1b0aabc4a3bfba91a3713c5c7f342b11941")
    end

  end

  describe "#content" do

    it "returns the Cartfile.resolved file contet" do
      expect(cartfile_resolved.content).to eq(File.read(cartfile_resolved_path))
    end

  end

  describe "#repositories_data" do

    it "returns an array of hashes with the repositories data" do
      expect(cartfile_resolved.repositories_data).to eq([
        {
          name: "mamaral/Neon",
          digest: "46c7e600644855b4967147cb2b7c79f64a23e634921585d944cf2e487be21e26"
        },
        {
          name: "antitypical/Result",
          digest: "142f7af128a6bc0fa6965b94ea2bb91d499781fee62a3a247d65cbeab4d00434"
        }
      ])
    end

  end

  describe "#repositories" do

    it "returns an array of repositories names" do
      expect(cartfile_resolved.repositories).to eq(["mamaral/Neon", "antitypical/Result"])
    end

  end

  describe "#repositories_digests" do

    it "returns an array with the digests of the repositories names" do
      expect(cartfile_resolved.repositories_digests).to eq([
        "46c7e600644855b4967147cb2b7c79f64a23e634921585d944cf2e487be21e26",
        "142f7af128a6bc0fa6965b94ea2bb91d499781fee62a3a247d65cbeab4d00434"
      ])
    end

  end

end
