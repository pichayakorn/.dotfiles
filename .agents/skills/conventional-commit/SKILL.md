---
name: conventional-commit
description: Git commit message generator and validator using the Conventional Commits v1.0.0 specification. Use when committing code changes to ensure consistent, SemVer-compatible history.
---

# Conventional Commit

## Overview

This skill guides the generation of commit messages following the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification. This format provides a lightweight set of rules for creating an explicit commit history, making it easier to write automated tools on top of.

## Structure

The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature (corresponds to SemVer MINOR).
- **fix**: A bug fix (corresponds to SemVer PATCH).
- **build**: Changes that affect the build system or external dependencies.
- **chore**: Other changes that don't modify src or test files.
- **ci**: Changes to CI configuration files and scripts.
- **docs**: Documentation only changes.
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc).
- **refactor**: A code change that neither fixes a bug nor adds a feature.
- **perf**: A code change that improves performance.
- **test**: Adding missing tests or correcting existing tests.

### Breaking Changes

A breaking change is indicated by an `!` after the type/scope, or by including `BREAKING CHANGE:` at the beginning of the footer.
Example: `feat!: send-email capability`

## Workflow

1.  **Analyze Changes**: Examine the staged changes to determine the appropriate type and scope.
2.  **Identify Scope**: (Optional) Use a noun describing a section of the codebase (e.g., `feat(parser): add support for x`).
3.  **Write Description**: A short summary of the code changes. Use the imperative, present tense: "change" not "changed" nor "changes".
4.  **Draft Message**: Combine the elements into the final message.
5.  **Confirm with User**: Present the proposed message to the user for approval before committing.

## Examples

- `feat(api): add user authentication endpoint`
- `fix: resolve race condition in connection pool`
- `docs: update installation instructions in README`
- `refactor!: migrate to new database driver` (Breaking Change)
- `chore(deps): bump version of lodash`
