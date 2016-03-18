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
          identifier: "v0.0.3",
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
          identifier: "1.0.2",
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

  describe "#dependencies_with_valid_search_patterns" do

    it "returns an array of search patterns in the Carthage folder for the Cartfile.resolved dependencies" do
      expect(project.dependencies_with_valid_search_patterns).to eq([
        {
          name: "mamaral/Neon",
          digest: "46c7e600644855b4967147cb2b7c79f64a23e634921585d944cf2e487be21e26",
          identifier: "v0.0.3",
          search_patterns: [
            "#{FIXTURE_PATH}/Carthage/Build/iOS/Neon.framework*",
          ]
        },
        {
          name: "antitypical/Result",
          identifier: "1.0.2",
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

  describe "#zip_instructions" do

    it "returns an array on zip information hashes" do
      expect(project.zip_instructions).to eq([
        {
          source_pattern: "#{FIXTURE_PATH}/Carthage/Build/iOS/Neon.framework*",
          destination_name: "mamaral/Neon-iOS-v0.0.3.zip",
          destination_path: File.join(TMP_PATH, cache_dir_name, "mamaral/Neon-iOS-v0.0.3.zip"),
          platform: "iOS"
        },
        {
          source_pattern: "#{FIXTURE_PATH}/Carthage/Build/iOS/Result.framework*",
          destination_name: "antitypical/Result-iOS-1.0.2.zip",
          destination_path: File.join(TMP_PATH, cache_dir_name, "antitypical/Result-iOS-1.0.2.zip"),
          platform: "iOS"
        },
        {
          source_pattern: "#{FIXTURE_PATH}/Carthage/Build/Mac/Result.framework*",
          destination_name: "antitypical/Result-Mac-1.0.2.zip",
          destination_path: File.join(TMP_PATH, cache_dir_name, "antitypical/Result-Mac-1.0.2.zip"),
          platform: "Mac"
        },
        {
          source_pattern: "#{FIXTURE_PATH}/Carthage/Build/tvOS/Result.framework*",
          destination_name: "antitypical/Result-tvOS-1.0.2.zip",
          destination_path: File.join(TMP_PATH, cache_dir_name, "antitypical/Result-tvOS-1.0.2.zip"),
          platform: "tvOS"
        },
        {
          source_pattern: "#{FIXTURE_PATH}/Carthage/Build/watchOS/Result.framework*",
          destination_name: "antitypical/Result-watchOS-1.0.2.zip",
          destination_path: File.join(TMP_PATH, cache_dir_name, "antitypical/Result-watchOS-1.0.2.zip"),
          platform: "watchOS"
        }
      ])
    end
  end

  describe "#archives_names" do

    it "returns the names of the archives for the dependencies on S3" do
      expect(project.archives_names).to eq([
        "mamaral/Neon/iOS/Neon-iOS-v0.0.3.zip",
        "mamaral/Neon/Mac/Neon-Mac-v0.0.3.zip",
        "mamaral/Neon/tvOS/Neon-tvOS-v0.0.3.zip",
        "mamaral/Neon/watchOS/Neon-watchOS-v0.0.3.zip",
        "antitypical/Result/iOS/Result-iOS-1.0.2.zip",
        "antitypical/Result/Mac/Result-Mac-1.0.2.zip",
        "antitypical/Result/tvOS/Result-tvOS-1.0.2.zip",
        "antitypical/Result/watchOS/Result-watchOS-1.0.2.zip"
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
