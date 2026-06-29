# Technical Decisions

## 2026-06-29 - Build Prompt Registry Before AI Engineering Gateway

Context: after `context-pack-builder`, `eval-harness`, and `backend-service-template`, the next proposed tooling assets were `prompt-registry` and `ai-engineering-gateway`. The workspace still lacked one canonical source of instruction patterns for common engineering tasks.

Options considered:

- build `ai-engineering-gateway` first
- build `prompt-registry` first

Choice: build `prompt-registry` first.

Pros:

- creates immediate reuse for every future engineering task
- gives cheap models a canonical instruction surface
- keeps the next asset small enough to validate end to end
- establishes the contracts a future gateway would actually route and govern

Cons:

- does not solve routing, budgeting, or audit at runtime
- still depends on callers to supply the right variables

Consequences:

- the gateway remains deferred until prompt contracts are stable enough to deserve operational governance
- prompt versions become first-class artifacts in the workspace

Verification evidence:

- `./bin/check`
- `ruby bin/prompt-registry materialize review --var repo_name=demo --var task_context='Review demo.' --var constraints='Be direct.' --var verification='Check the contract.'`

## 2026-06-29 - Keep Prompt Templates File-Based With A Simple Manifest

Context: the first registry needs to be diffable, easy to review, and cheap for models to inspect in a local workspace.

Options considered:

- prompt files only, with no manifest
- a manifest plus Markdown files
- a database or remote service

Choice: use one YAML manifest plus Markdown template files.

Pros:

- metadata is centralized and easy to validate
- prompt text stays readable in normal diffs
- standard library YAML parsing is enough for the MVP

Cons:

- some information is duplicated between manifest and file tree
- local files do not provide remote distribution by themselves

Consequences:

- the registry can validate itself with a small Ruby codebase
- future serving layers should consume this manifest rather than invent another source of truth

Verification evidence:

- `bundle exec rake test`
- `ruby bin/prompt-registry validate`
