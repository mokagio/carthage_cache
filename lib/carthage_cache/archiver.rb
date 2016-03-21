module CarthageCache

  class Archiver

    attr_reader :executor

    def initialize(executor = ShellCommandExecutor.new)
      @executor = executor
    end

    def archive_contents_of_folder(archive_path, destination_path)
      files = Dir[archive_path]
      .map { |d| Dir.entries(d) }
      .flatten
      .select { |x| !x.start_with?(".") }
      puts "#{files}"
      executor.execute("cd #{archive_path} && zip -r -X #{File.expand_path(destination_path)} #{files.join(' ')} > /dev/null")
    end

    def archive_matching_pattern_in_folder(source_folder, pattern, archive_path)
      command = "pushd #{source_folder}; mkdir -p #{File.dirname(archive_path)}; zip -r #{archive_path} #{pattern} > /dev/null; popd"
      executor.execute(command)
    end

    def unarchive(archive_path, destination_path)
      executor.execute("unzip -o #{archive_path} -d #{destination_path} > /dev/null")
    end

  end

end
