require "digest"

module CarthageCache

  class CartfileResolvedFile

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def digest
      @digest ||= Digest::SHA256.hexdigest(content)
    end

    def content
      @content ||= File.read(file_path)
    end

    def dependencies
      # Note: this code is not very robust.
      # The Cartfile syntax is a strict subset of OGDL, we might want to
      # consider better parsing strategies in the future
      content.lines
        .select { |line| line[0] == 'g' } # g as in git and github
        .map do |line|
          {
            name: line.split(' ')[1].gsub('"', ''),
            digest: Digest::SHA256.hexdigest(line)
          }
        end
    end

  end

end
