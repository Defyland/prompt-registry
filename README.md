# Prompt Registry

`prompt-registry` is the canonical prompt library for `backend-challenges`. It gives cheap models and human reviewers one versioned source of truth for common engineering task types: review, feature work, bugfixes, docs, migrations, security audits, and release readiness.

This repository is intentionally a real registry, not a wiki dump. It ships:

- versioned prompt templates in Markdown
- one registry manifest that defines metadata and placeholders
- a CLI to list, show, materialize, and validate prompts
- executable tests that prove the registry stays coherent

## Why This Exists

The workspace already has:

- `context-pack-builder` to package clean repository context
- `eval-harness` to measure readiness
- `backend-service-template` to standardize new service bootstraps

What was still missing was a canonical instruction layer. Without it, each task starts with ad hoc prompt phrasing and the quality of cheap-model output depends too much on whoever typed the request. `prompt-registry` closes that gap with a small, versioned, auditable surface.

## What This Registry Proves

- task-type prompts are versioned and discoverable
- placeholders are explicit and validated
- one CLI can materialize a prompt with concrete values
- the prompt contract itself can be tested in CI

## What This Registry Intentionally Does Not Prove

- runtime model routing or spend controls
- remote prompt hosting or API delivery
- live experimentation or analytics

Those belong in a future gateway only after prompt contracts are stable enough to govern.

## Five-Minute Evaluation

Run the repository contract:

```sh
./bin/check
```

List the available prompts:

```sh
ruby bin/prompt-registry list
```

Materialize one prompt:

```sh
ruby bin/prompt-registry materialize review \
  --var repo_name=bankport-go-gin-partner-api \
  --var task_context='Review the latest partner API hardening diff.' \
  --var constraints='Find real regressions first. Keep the tone direct.' \
  --var verification='Check tests, contracts, and auth assumptions.'
```

## Available Prompt Types

- `review`
- `feature`
- `bugfix`
- `docs`
- `migration`
- `security-audit`
- `release-readiness`

Each prompt is currently published as `v1`.

## CLI

List prompts:

```sh
ruby bin/prompt-registry list
```

Show the raw template:

```sh
ruby bin/prompt-registry show review
```

Materialize a template with variables:

```sh
ruby bin/prompt-registry materialize release-readiness \
  --var repo_name=prompt-registry \
  --var task_context='Prepare the repo for publication.' \
  --var constraints='Do not overstate verification.' \
  --var verification='Run the local contract and readiness evaluation.'
```

Validate the whole registry:

```sh
ruby bin/prompt-registry validate
```

## Registry Contract

The authoritative metadata lives in [registry/prompts.yml](./registry/prompts.yml).

Every prompt entry must define:

- `id`
- `version`
- `summary`
- `path`
- `placeholders`

Every referenced template file must exist and include all declared placeholders in `{{placeholder_name}}` form.

## Architecture Overview

The repository has three parts:

- `registry/prompts.yml`: canonical manifest of prompt metadata
- `prompts/**/v1.md`: versioned Markdown prompt templates
- `lib/prompt_registry`: loader, validator, materializer, and CLI

More detail lives in [docs/architecture.md](./docs/architecture.md).

## Verification Surface

`bin/check` is the root contract:

- `bundle exec rake test`
- `ruby bin/prompt-registry validate`
- `ruby bin/prompt-registry list`

CI runs the same contract.

## Tradeoffs

- Markdown templates are easy to inspect and diff, but less structured than a remote prompt service.
- Placeholder substitution stays intentionally simple; the registry optimizes for canonical wording, not full templating logic.
- The first version is local-only and file-based because the workspace still benefits more from prompt correctness than from gateway infrastructure.

## Known Limits

- Only one version per task type exists today.
- There is no prompt scoring or A/B experimentation yet.
- Materialization is plain placeholder replacement, not a policy engine.
