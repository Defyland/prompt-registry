# frozen_string_literal: true

require "test_helper"

class PromptRegistryTest < Minitest::Test
  def test_validate_passes_for_real_registry
    registry = PromptRegistry::Registry.new(File.expand_path("..", __dir__))

    assert PromptRegistry::Validator.new(registry).validate!
  end

  def test_materialize_substitutes_all_placeholders
    registry = PromptRegistry::Registry.new(File.expand_path("..", __dir__))
    entry = registry.find("review", "v1")

    output = PromptRegistry::Materializer.new(registry).materialize(entry, {
      "repo_name" => "demo-repo",
      "task_context" => "Review the latest demo diff.",
      "constraints" => "Focus on real regressions.",
      "verification" => "Check tests and contracts."
    })

    assert_includes output, "demo-repo"
    assert_includes output, "Review the latest demo diff."
    refute_includes output, "{{repo_name}}"
  end

  def test_materialize_fails_when_values_are_missing
    registry = PromptRegistry::Registry.new(File.expand_path("..", __dir__))
    entry = registry.find("review", "v1")

    error = assert_raises(RuntimeError) do
      PromptRegistry::Materializer.new(registry).materialize(entry, {
        "repo_name" => "demo-repo"
      })
    end

    assert_includes error.message, "missing values"
  end

  def test_cli_lists_registry_entries
    stdout = StringIO.new
    stderr = StringIO.new

    status = PromptRegistry::CLI.new(["list"], stdout: stdout, stderr: stderr).call

    assert_equal 0, status
    assert_includes stdout.string, "review@v1"
    assert_includes stdout.string, "release-readiness@v1"
    assert_empty stderr.string
  end

  def test_cli_materializes_prompt
    stdout = StringIO.new
    stderr = StringIO.new

    status = PromptRegistry::CLI.new([
      "materialize",
      "review",
      "--var", "repo_name=demo-repo",
      "--var", "task_context=Review the demo diff.",
      "--var", "constraints=Find real bugs first.",
      "--var", "verification=Check tests."
    ], stdout: stdout, stderr: stderr).call

    assert_equal 0, status
    assert_includes stdout.string, "demo-repo"
    assert_includes stdout.string, "Review the demo diff."
    assert_empty stderr.string
  end

  def test_validator_rejects_missing_placeholder
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "registry"))
      FileUtils.mkdir_p(File.join(dir, "prompts/review"))
      File.write(File.join(dir, "registry/prompts.yml"), <<~YAML)
        prompts:
          - id: review
            version: v1
            summary: Demo
            path: prompts/review/v1.md
            placeholders:
              - repo_name
              - task_context
      YAML
      File.write(File.join(dir, "prompts/review/v1.md"), "# Demo\n\n{{repo_name}}\n")

      registry = PromptRegistry::Registry.new(dir)
      error = assert_raises(RuntimeError) { PromptRegistry::Validator.new(registry).validate! }

      assert_includes error.message, "{{task_context}}"
    end
  end
end
