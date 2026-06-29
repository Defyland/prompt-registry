# frozen_string_literal: true

module PromptRegistry
  class Validator
    def initialize(registry)
      @registry = registry
    end

    def validate!
      labels = {}

      @registry.entries.each do |entry|
        raise "duplicate prompt entry #{entry.label}" if labels.key?(entry.label)

        labels[entry.label] = true
        absolute = File.join(@registry.root, entry.path)
        raise "missing prompt file #{entry.path}" unless File.file?(absolute)

        body = @registry.prompt_body(entry)
        entry.placeholders.each do |placeholder|
          token = "{{#{placeholder}}}"
          raise "missing placeholder #{token} in #{entry.path}" unless body.include?(token)
        end
      end

      true
    end
  end
end
