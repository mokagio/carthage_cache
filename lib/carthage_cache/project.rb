module CarthageCache

  class Project

    attr_reader :cartfile
    attr_reader :project_path
    attr_reader :cache_dir_name
    attr_reader :terminal
    attr_reader :tmpdir_base_path

    def initialize(project_path, cache_dir_name, terminal, tmpdir)
      @project_path = project_path
      @cache_dir_name = cache_dir_name
      @terminal = terminal
      @tmpdir_base_path = tmpdir
      @cartfile = CartfileResolvedFile.new(cartfile_resolved_path)
    end

    def archive_filename
      @archive_filename ||= "#{archive_key}.zip"
    end

    def archive_key
      cartfile.digest
    end

    def dependencies
      cartfile.dependencies
    end

    def dependencies_search_patterns
      cartfile.dependencies.each do |dependency|
        name = dependency[:name].split('/').last

        dependency[:search_patterns] = ['iOS', 'Mac', 'tvOS', 'watchOS'].map do |platform|
          File.join(project_path, 'Carthage', 'Build', platform, "#{name}.framework*")
        end
      end
    end

    # TODO: this is probably not the best place where to put this method
    # SRP!
    #
    # Returns map of dependencies with only the search patterns that actually
    # produce a result
    def dependencies_with_valid_search_patterns
      dependencies_search_patterns.each do |dependency|
        dependency[:search_patterns] = dependency[:search_patterns].select { |p| Dir[p].count != 0 }
      end
    end

    # TODO: this is probably not the best place where to put this method
    # SRP!
    #
    def zip_instructions
      dependencies_with_valid_search_patterns.map do |dependency|
        dependency[:search_patterns].map do |pattern|
          # TODO: This is not very safe...
          # We need to go backwards due to pattern being contextual to the file
          # system:
          #
          # /i/dont/know/how/many/foders/there/are/Carthage/Build/platform/Name.framework*
          platform = pattern.split('/')[-2]
          name = "#{dependency[:name]}-#{platform}-#{dependency[:identifier]}.zip"
          {
            source_pattern: pattern,
            destination_name: name,
            destination_path: File.join(tmpdir, name)
          }
        end
      end
      .flatten
    end

    def tmpdir
      @tmpdir ||= create_tmpdir
    end

    def carthage_build_directory
      @carthage_build_directory ||= File.join(project_path, "Carthage", "Build")
    end

    private

      def cartfile_resolved_path
        @carfile_resolved_path ||= File.join(project_path, "Cartfile.resolved")
      end

      def create_tmpdir
        dir = File.join(tmpdir_base_path, cache_dir_name)
        unless File.exist?(dir)
          terminal.vputs "Creating carthage cache directory at '#{dir}'."
          FileUtils.mkdir_p(dir)
        end
        dir
      end

  end

end
