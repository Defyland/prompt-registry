# frozen_string_literal: true

require "yaml"

module PromptRegistry
  class Registry
    def initialize(root = File.expand_path("../..", __dir__))
      @root = root
    end

    attr_reader :root

    def entries
      @entries ||= begin
        data = YAML.load_file(File.join(root, "registry", "prompts.yml"))
        Array(data.fetch("prompts")).map do |row|
          PromptEntry.new(
            id: row.fetch("id"),
            version: row.fetch("version"),
            summary: row.fetch("summary"),
            path: row.fetch("path"),
            placeholders: Array(row.fetch("placeholders"))
          )
        end
      end
    end

    def find(id, version = "v1")
      entries.find { |entry| entry.id == id && entry.version == version }
    end

    def prompt_body(entry)
      File.read(File.join(root, entry.path), mode: "r:BOM|UTF-8")
    end
  end
end
