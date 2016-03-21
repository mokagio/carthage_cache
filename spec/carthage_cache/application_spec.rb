require "spec_helper"
require "fileutils"

describe CarthageCache::Application do

  let(:repository) { double("repository") }
  let(:options) { { repository: double("repository_class", new: repository), terminal: MockTerminal } }
  let(:archive_filename) { "a7389856777fbb43a5c5eecf4b30a1b0aabc4a3bfba91a3713c5c7f342b11941.zip" }
  let(:tmpdir) { File.join(TMP_PATH, "carthage_cache") }
  let(:archive_path) { File.join(tmpdir, archive_filename) }
  subject(:application) { CarthageCache::Application.new(FIXTURE_PATH, false, { tmpdir: TMP_PATH }, options) }

  describe "#archive_exist?" do

    context "when there is no archive for the given Cartfile.resolved file" do

      it "returns false" do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
        expect(application.archive_exist?).to be_falsy
      end

    end

    context "when there is an archive for the given Cartfile.resolved file" do

      it "returns true" do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        expect(application.archive_exist?).to be_truthy
      end

    end

  end

  describe "#existing_single_archives" do

    context "when no single archive exists for any of the dependencies in the Carfile.resolved file" do

      it "returns an empty array" do
        expect(repository).to receive('archive_exist?').at_least(1).and_return(false)

        expect(application.existing_single_archives).to eq([])
      end

    end

    context "when some archives exist for dependencies in the Carfile.resolved file" do

      it "returns the names of those archives" do
        expect(repository).to receive("archive_exist?").with("mamaral/Neon/iOS/Neon-iOS-v0.0.3.zip").and_return(true)
        expect(repository).to receive("archive_exist?").with("antitypical/Result/Mac/Result-Mac-1.0.2.zip").and_return(true)
        expect(repository).to receive('archive_exist?').at_least(1).and_return(false)

        expect(application.existing_single_archives).to eq([
          "mamaral/Neon/iOS/Neon-iOS-v0.0.3.zip",
          "antitypical/Result/Mac/Result-Mac-1.0.2.zip"
        ])
      end

    end

  end

  describe "#install_archive" do

    before(:each) do
      FileUtils.cp(File.join(tmpdir, "archive.zip"), archive_path)
    end

    after(:each) do
      FileUtils.rm(archive_path)
    end

    context "when there is no archive for the given Cartfile.resolved file" do

      before(:each) do
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
      end

      it "returns false" do
        expect(application.install_archive).to be_falsy
      end

    end

    context "when there is an archive for the given Cartfile.resolved file" do

      let(:carthage_build_directory) { File.join(FIXTURE_PATH, "Carthage/Build") }

      before(:each) do
        expect(repository).to receive(:download).with(archive_filename, archive_path)
        expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        FileUtils.rm_r(carthage_build_directory) if File.exist?(carthage_build_directory)
      end

      it "returns true" do
        expect(application.install_archive).to be_truthy
      end

      it "downloads and install the archive" do
        application.install_archive
        expect(File.exist?(carthage_build_directory)).to be_truthy
      end

    end

  end

  describe "#install_single_archives" do

    let(:carthage_build_directory) { File.join(FIXTURE_PATH, "Carthage/Build") }

    context "when there are no archives for the given Cartfile.resolved file" do

      before(:each) do
        expect(repository).to receive("archive_exist?").at_least(1).and_return(false)
      end

      it "returns []" do
        expect(application.install_single_archives).to eq([])
      end

    end

    context "when only some of the dependencies in the Cartfile.resolved file have a matching archives" do

      before(:each) do
        expect(repository).to receive("archive_exist?").with("mamaral/Neon/iOS/Neon-iOS-v0.0.3.zip").and_return(true)
        expect(repository).to receive("archive_exist?").with("antitypical/Result/Mac/Result-Mac-1.0.2.zip").and_return(true)
        expect(repository).to receive("archive_exist?").at_least(1).and_return(false)
      end

      it "returns an array with the names of the available archives" do
        expect(application.install_single_archives).to eq([
          "mamaral/Neon/iOS/Neon-iOS-v0.0.3.zip",
          "antitypical/Result/Mac/Result-Mac-1.0.2.zip"
        ])
      end

      it "unarchives each of the available archives to the correct location in the Carthage/Build folder" do
        application.install_single_archives
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Neon.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Neon.framework.dSYM")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Result.framework")))
      end

    end

    context "when all the dependencies in the Cartfile.resolved file have a matching archives" do

      before(:each) do
        expect(repository).to receive("archive_exist?").at_least(1).and_return(true)
      end

      it "returns an array with the names of the available archives" do
        expect(application.install_single_archives).to eq([
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

      it "unarchives each of the available archives to the correct location in the Carthage/Build folder" do
        application.install_single_archives
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Neon.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Neon.framework.dSYM")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Neon.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Neon.framework.dSYM")))
        expect(File.exists?(File.join(carthage_build_directory, "tvOS", "Neon.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "tvOS", "Neon.framework.dSYM")))
        expect(File.exists?(File.join(carthage_build_directory, "watchOS", "Neon.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "watchOS", "Neon.framework.dSYM")))
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "iOS", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "Mac", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "tvOS", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "tvOS", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "watchOS", "Result.framework")))
        expect(File.exists?(File.join(carthage_build_directory, "watchOS", "Result.framework")))
      end

    end

  end

  describe "#create_archive" do

    after(:each) do
      FileUtils.rm(archive_path) if File.exist?(archive_path)
    end

    context "when a the force parameter is set to true" do

      context "when an archive already exists" do

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive(true)
        end

      end

      context "when an archive does not exists" do

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive(true)
        end

      end

    end

    context "when a the force parameter is set to false" do

      context "when an archive already exists" do

        before(:each) do
          expect(repository).to receive("archive_exist?").with(archive_filename).and_return(true)
        end

        it("returns false") do
          expect(application.create_archive).to be_falsy
        end

        it("does not upload the archive") do
          expect(repository).not_to receive(:upload)
          application.create_archive
        end

      end

      context "when an archive does not exists" do

        before(:each) do
          expect(repository).to receive("archive_exist?").with(archive_filename).and_return(false)
        end

        it("uploads the archive") do
          expect(repository).to receive(:upload).with(archive_filename, archive_path)
          application.create_archive
        end

      end

    end

  end

  shared_examples_for "uploads all the archives" do |force|
    it "adds objects to the end of the collection" do
      expect(repository).to receive(:upload).with(
        "mamaral/Neon-iOS-v0.0.3.zip",
        File.join(tmpdir, "mamaral/Neon-iOS-v0.0.3.zip")
      )
      expect(repository).to receive(:upload).with(
        "antitypical/Result-iOS-1.0.2.zip",
        File.join(tmpdir, "antitypical/Result-iOS-1.0.2.zip")
      )
      expect(repository).to receive(:upload).with(
        "antitypical/Result-Mac-1.0.2.zip",
        File.join(tmpdir, "antitypical/Result-Mac-1.0.2.zip"))
      expect(repository).to receive(:upload).with(
        "antitypical/Result-tvOS-1.0.2.zip",
        File.join(tmpdir, "antitypical/Result-tvOS-1.0.2.zip")
      )
      expect(repository).to receive(:upload).with(
        "antitypical/Result-watchOS-1.0.2.zip",
        File.join(tmpdir, "antitypical/Result-watchOS-1.0.2.zip")
      )

      application.create_single_archives(force)
    end
  end

  describe "#create_single_archives" do

    context "when the force parameter is set to true" do

      context "when archives for each dependency already exist" do
        it_should_behave_like "uploads all the archives", true
      end

      context "when archives exist only for some dependencies" do
        it_should_behave_like "uploads all the archives", true
      end

      context "when there are no archives for any of the dependencies" do
        it_should_behave_like "uploads all the archives", true
      end

    end

    context "when the force parameter is set to false" do

      context "when archives for each dependency already exist" do
        before(:each) do
          expect(repository).to receive("archive_exist?").at_least(1).and_return(true)
        end

        it "does not upload any archive" do
          expect(repository).not_to receive(:upload)
          application.create_single_archives(false)
        end

        it "returns false" do
          expect(application.create_single_archives).to be_falsy
        end

      end

      context "when archives exist only for some dependencies" do
        before(:each) do
          expect(repository).to receive("archive_exist?").with("mamaral/Neon-iOS-v0.0.3.zip").and_return(true)
          expect(repository).to receive("archive_exist?").at_least(1).and_return(false)
        end

        it "uploads only the archives for those that do not exist" do
          expect(repository).to receive(:upload).with(
            "antitypical/Result-iOS-1.0.2.zip",
            File.join(tmpdir, "antitypical/Result-iOS-1.0.2.zip")
          )
          expect(repository).to receive(:upload).with(
            "antitypical/Result-Mac-1.0.2.zip",
            File.join(tmpdir, "antitypical/Result-Mac-1.0.2.zip")
          )
          expect(repository).to receive(:upload).with(
            "antitypical/Result-tvOS-1.0.2.zip",
            File.join(tmpdir, "antitypical/Result-tvOS-1.0.2.zip")
          )
          expect(repository).to receive(:upload).with(
            "antitypical/Result-watchOS-1.0.2.zip",
            File.join(tmpdir, "antitypical/Result-watchOS-1.0.2.zip")
          )

          application.create_single_archives(false)
        end

      end

      context "when there are no archives for any of the dependencies" do
        before(:each) do
          expect(repository).to receive("archive_exist?").at_least(1).and_return(false)
        end

        it_should_behave_like "uploads all the archives", false
      end

    end

  end

end
