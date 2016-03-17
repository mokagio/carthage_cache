require "spec_helper"

describe CarthageCache::Project do

  let(:cache_dir_name) { "spec_carthage_cache" }
  let(:terminal) { MockTerminal.new(false) }
  subject(:project) { CarthageCache::Project.new(FIXTURE_PATH, cache_dir_name, terminal, TMP_PATH) }

  describe "#archive_key" do

    it "returns the digest of the Cartfile.resolved file" do
      expect(project.archive_key).to eq("a7389856777fbb43a5c5eecf4b30a1b0aabc4a3bfba91a3713c5c7f342b11941")
    end

  end

  describe "#archive_filename" do

    it "returns the name of the archive for the current Cartfile.resolved file" do
      expect(project.archive_filename).to eq("a7389856777fbb43a5c5eecf4b30a1b0aabc4a3bfba91a3713c5c7f342b11941.zip")
    end

  end

  describe "#dependencies" do

    it "returns an array of hashes describing the Carfile.resolved dependencies" do
      expect(project.dependencies).to eq([
        {
          name: "mamaral/Neon",
          identifier: "v0.0.3",
          digest: "46c7e600644855b4967147cb2b7c79f64a23e634921585d944cf2e487be21e26"
        },
        {
          name: "antitypical/Result",
          identifier: "1.0.2",
          digest: "142f7af128a6bc0fa6965b94ea2bb91d499781fee62a3a247d65cbeab4d00434"
        }
      ])
    end
  end

  describe "#dependencies_search_patterns" do

    it "returns an array of search patterns in the Carthage folder for the Cartfile.resolved dependencies" do
      expect(project.dependencies_search_patterns).to eq([
        {
          name: "mamaral/Neon",
          digest: "46c7e600644855b4967147cb2b7c79f64a23e634921585d944cf2e487be21e26",
          search_patterns: [
            "#{FIXTURE_PATH}/Carthage/Build/iOS/Neon.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/Mac/Neon.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/tvOS/Neon.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/watchOS/Neon.framework*",
          ]
        },
        {
          name: "antitypical/Result",
          digest: "142f7af128a6bc0fa6965b94ea2bb91d499781fee62a3a247d65cbeab4d00434",
          search_patterns: [
            "#{FIXTURE_PATH}/Carthage/Build/iOS/Result.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/Mac/Result.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/tvOS/Result.framework*",
            "#{FIXTURE_PATH}/Carthage/Build/watchOS/Result.framework*",
          ]
        }
      ])
    end
  end

  describe "#carthage_build_directory" do

    it "returns the project's Carthage build directory" do
      expect(project.carthage_build_directory).to eq(File.join(FIXTURE_PATH, "Carthage/Build"))
    end

  end

  describe "#tmpdir" do

    it "returns the project's temporary directory" do
      expect(project.tmpdir).to eq(File.join(TMP_PATH, cache_dir_name))
    end

  end

end
