# frozen_string_literal: true

require "optparse"

module PromptRegistry
  class CLI
    def initialize(argv, stdout:, stderr:, registry: Registry.new)
      @argv = argv.dup
      @stdout = stdout
      @stderr = stderr
      @registry = registry
    end

    def call
      command = @argv.shift
      case command
      when "list"
        Validator.new(@registry).validate!
        list
      when "show"
        Validator.new(@registry).validate!
        show(@argv)
      when "materialize"
        Validator.new(@registry).validate!
        materialize(@argv)
      when "validate"
        Validator.new(@registry).validate!
        @stdout.puts "Registry valid"
        0
      else
        raise OptionParser::ParseError, "unknown command #{command.inspect}"
      end
    rescue KeyError, OptionParser::ParseError, RuntimeError => error
      @stderr.puts "error: #{error.message}"
      @stderr.puts usage
      64
    end

    private

    def list
      @registry.entries.each do |entry|
        @stdout.puts "#{entry.label}\t#{entry.summary}"
      end
      0
    end

    def show(argv)
      id, version = resolve_entry_args(argv)
      entry = @registry.find(id, version)
      raise KeyError, "prompt #{id}@#{version} not found" unless entry

      @stdout.puts @registry.prompt_body(entry)
      0
    end

    def materialize(argv)
      values = {}
      parser = OptionParser.new do |opts|
        opts.on("--var KEY=VALUE", "Provide one placeholder value") do |pair|
          key, value = pair.split("=", 2)
          raise OptionParser::ParseError, "--var requires KEY=VALUE" if key.to_s.empty? || value.nil?

          values[key] = value
        end
      end
      parser.parse!(argv)

      id, version = resolve_entry_args(argv)
      entry = @registry.find(id, version)
      raise KeyError, "prompt #{id}@#{version} not found" unless entry

      @stdout.puts Materializer.new(@registry).materialize(entry, values)
      0
    end

    def resolve_entry_args(argv)
      id = argv.shift
      raise KeyError, "prompt id is required" if id.to_s.empty?

      version = "v1"
      if (index = argv.index("--version"))
        version = argv.fetch(index + 1)
        argv.slice!(index, 2)
      end

      [id, version]
    end

    def usage
      <<~USAGE
        Usage:
          prompt-registry list
          prompt-registry show ID [--version VERSION]
          prompt-registry materialize ID [--version VERSION] --var KEY=VALUE [--var KEY=VALUE...]
          prompt-registry validate
      USAGE
    end
  end
end
