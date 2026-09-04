# .NET Performance Dashboard

A reusable GitHub repository template for repeatable cross-platform .NET performance analysis with GitHub Actions and GitHub Pages. The repository contains configuration and orchestration only; collection and report generation are provided by [DotNetPerformanceLab](https://github.com/NeverMorewd/DotNetPerformanceLab).

## What it provides

- Manual benchmarks for Windows, Linux, and macOS.
- Optional trusted scheduled benchmarks.
- Caller-controlled .NET 8+ SDK selection and Native AOT, self-contained, trimmed, or framework-dependent publishing.
- Synchronized process and host CPU, memory, I/O, network, load, and lifecycle metrics.
- `System.Runtime` and optional application `System.Diagnostics.Metrics` instruments.
- Offline Plotly reports, normalized JSON and CSV, Markdown summaries, and optional EventPipe traces.
- A GitHub Pages history rebuilt from unexpired workflow artifacts.
- A single reviewed target configuration with JSON Schema editor support.

## Create a dashboard

Use **Use this template → Create a new repository** instead of forking this repository. GitHub normally permits only one fork of an upstream repository per account, while a template can create any number of independent dashboard repositories.

Each dashboard repository is intentionally configured for one target repository. To measure multiple applications, create one repository from this template for each target—for example, `AppA.Performance` and `AppB.Performance`. Every dashboard then has independent workflow history, report artifacts, retention settings, runners, and GitHub Pages deployment.

1. Select **Use this template → Create a new repository** on this repository's GitHub page.
2. Edit [`performance-target.json`](performance-target.json) for the target repository, ref, .NET SDK, project, platforms, publishing options, and measurement policy. Set `target.repository` to GitHub's `owner/repository` identifier, not a full URL.
3. Register dedicated self-hosted measurement runners with `self-hosted`, `metric-test`, and the matching `Windows`, `Linux`, or `macOS` labels.
4. Create a protected `performance-lab` Environment. Require approval when personal or shared machines execute target code.
5. In **Settings → Pages**, select **GitHub Actions** as the source.
6. Run **Validate dashboard configuration**.
7. Run **Run performance benchmark** with **quick validation** enabled.
8. Review the artifact and Pages deployment before running the full configured benchmark.

The target may be your own repository or any public GitHub repository whose license and usage terms permit the intended build and analysis. No secret is needed for a public target. For a private target, create `TARGET_REPOSITORY_TOKEN` with fine-grained, read-only Contents access to that repository. Do not use an administrator token.

Repositories created from a template are independent and do not automatically receive later template changes. DotNetPerformanceLab upgrades remain reviewable because the reusable workflow commit pins are managed by Dependabot; structural changes to this dashboard template must be synchronized deliberately.

## Configuration

`performance-target.json` is the only target-specific file. Paths are relative to the checked-out target repository and may not contain parent traversal segments.

The dashboard, rather than DotNetPerformanceLab, owns source checkout and publishing. [`build-target.yml`](.github/workflows/build-target.yml) selects the configured SDK, performs a locked or unlocked restore, publishes on a GitHub-hosted runner, and uploads a short-lived application artifact. The pinned `profile-artifact.yml` workflow downloads that artifact on the dedicated measurement runner. This boundary keeps repository-specific build policy outside the reusable performance toolkit.

`publish.dotnetVersion` must select a supported .NET 8, 9, or 10 SDK, such as `10.0.x` or an exact feature-band version. Each platform also selects its `buildRunner`; the checked-in values use GitHub-hosted runners. Exact SDK versions, explicit runner images, and immutable target commits are recommended for comparable long-term measurements.

Projects that need workloads, code generation, signing, or other repository-specific preparation can extend [`build-target.yml`](.github/workflows/build-target.yml). Keep those steps in the dashboard repository and continue handing DotNetPerformanceLab only the final application artifact.

The checked-in configuration is a neutral template and must be customized before running a benchmark. It demonstrates all three operating systems without referring to a real target repository. Set `schedule.enabled` to `true` only after every listed runner is available. Scheduled workflows execute code from the configured target ref, including third-party code, so review the target and use a protected branch, immutable tag, or commit.

## Workflows

| Workflow | Purpose |
|---|---|
| Validate dashboard configuration | Fast configuration validation on pushes and pull requests |
| Run performance benchmark | Manual single-platform benchmark with optional quick mode and ref override |
| Run scheduled performance benchmarks | Weekly configured platform matrix; disabled by default |
| Refresh performance report history | Daily Pages rebuild so expired artifacts disappear |

Performance workflows never run for pull requests. Target code is built only after a manual dispatch or an explicitly enabled default-branch schedule. The resulting artifact executes on a self-hosted runner only inside the `performance-lab` Environment.

## Measurement guidance

Use fixed physical runners, power settings, workload, display topology, and application state. Compare runs from the same machine and operating system. Cross-machine results are descriptive, not regression evidence. A positive memory trend is a signal for deeper analysis rather than proof of a leak.

## Versioning

Reusable workflows are pinned to immutable DotNetPerformanceLab commit SHAs. Dependabot opens reviewable updates instead of silently following `main`. Replace development SHAs with an official major release after it is published.

## License

Licensed under the [MIT License](LICENSE).
