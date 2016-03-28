module CarthageCache

  class Application

    CACHE_DIR_NAME = "carthage_cache"

    attr_reader :terminal
    attr_reader :archiver
    attr_reader :repository
    attr_reader :project
    attr_reader :config

    def initialize(project_path, verbose, config, repository: Repository, terminal: Terminal)
      @terminal = terminal.new(verbose)
      @archiver = Archiver.new
      @config = Configurator.new(project_path, config).config
      @repository = repository.new(@config.bucket_name, @config.hash_object[:aws_s3_client_options])
      @project = Project.new(project_path, CACHE_DIR_NAME, terminal, @config.tmpdir)
    end

    def archive_exist?
      repository.archive_exist?(project.archive_filename)
    end

    def existing_single_archives
      existing_archives = project.archives_names.select do |name|
        repository.archive_exist?(name)
      end
    end

    def install_archive
      if archive_exist?
        archive_installer.install
        true
      else
        terminal.puts "There is no cached archive for the current Cartfile.resolved file."
        false
      end
    end

    def install_single_archives
      existing_archives = existing_single_archives
      unarchive_instructions = existing_archives.map do |name|
        {
          source: name,
          destination: 
        }
      end
      .each do |instruction|
        archiver.unarchive()
      end

      existing_archives
    end

    def create_archive(force = false)
      archive_builder.build if force || !archive_exist?
    end

    def create_single_archives(force = false)
      zip_instructions = project.zip_instructions
      zip_instructions = zip_instructions.select { |i| !repository.archive_exist?(i[:destination_name]) } unless force

      return false if zip_instructions.count == 0

      zip_instructions.each do |zip_instruction|
        source_folder = zip_instruction[:source_pattern].split('/')[0...-1].join('/')
        pattern = zip_instruction[:source_pattern].split('/').last
        archiver.archive_matching_pattern_in_folder(source_folder, pattern, zip_instruction[:destination_path])
      end

      upload_instructions = zip_instructions.map do|zip_instruction|
        {
          source_path: zip_instruction[:destination_path],
          destination_name: zip_instruction[:destination_name]
        }
      end

      upload_instructions.each do |instruction|
        puts "Uploading archive with name #{instruction[:destination_name]}"

        repository.upload(instruction[:destination_name], instruction[:source_path])
      end
    end

    private

      def archive_installer
        @archive_installer ||= ArchiveInstaller.new(terminal, repository, archiver, project)
      end

      def archive_builder
        @archive_builder ||= ArchiveBuilder.new(terminal, repository, archiver, project)
      end

  end

end
