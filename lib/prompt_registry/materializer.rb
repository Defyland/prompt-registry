# frozen_string_literal: true

module PromptRegistry
  class Materializer
    def initialize(registry)
      @registry = registry
    end

    def materialize(entry, values)
      missing = entry.placeholders.reject { |name| values.key?(name) }
      raise "missing values for #{missing.join(', ')}" unless missing.empty?

      body = @registry.prompt_body(entry)
      entry.placeholders.each do |name|
        body = body.gsub("{{#{name}}}", values.fetch(name))
      end
      body
    end
  end
end
