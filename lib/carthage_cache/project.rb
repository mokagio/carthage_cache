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
