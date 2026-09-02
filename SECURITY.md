# Security policy

## Performance runners

Performance workflows execute the target repository's code. Use dedicated, non-administrator self-hosted runner accounts and do not expose them to pull-request workflows. Desktop applications require an interactive user session; Windows Session 0 and headless desktop sessions are not representative environments.

Protect the `performance-lab` Environment with required reviewers. Configure scheduled measurements only for a protected branch, trusted tag, or immutable commit.

## Private targets

Use a fine-grained token with read-only Contents access to the single target repository. Store it as `TARGET_REPOSITORY_TOKEN`. The reusable workflow passes it only to checkout and disables persisted credentials.

Do not place credentials in `performance-target.json`, command arguments, report labels, repository variables, artifact names, or application configuration committed to this repository.

## Reporting vulnerabilities

Report security issues privately through the repository's GitHub Security Advisory interface. Do not open a public issue containing credentials, runner details, or an exploitable workflow configuration.
