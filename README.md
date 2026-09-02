# .NET Performance Dashboard

A forkable GitHub Actions and GitHub Pages dashboard for repeatable cross-platform .NET performance analysis. The repository contains configuration and orchestration only; collection and report generation are provided by [DotNetPerformanceLab](https://github.com/NeverMorewd/DotNetPerformanceLab).

## What it provides

- Manual benchmarks for Windows, Linux, and macOS.
- Optional trusted scheduled benchmarks.
- Native AOT, self-contained, trimmed, or framework-dependent publishing.
- Synchronized process and host CPU, memory, I/O, network, load, and lifecycle metrics.
- `System.Runtime` and optional application `System.Diagnostics.Metrics` instruments.
- Offline Plotly reports, normalized JSON and CSV, Markdown summaries, SVG charts, and optional EventPipe traces.
- A GitHub Pages history rebuilt from unexpired workflow artifacts.
- A single reviewed target configuration with JSON Schema editor support.

## Fork setup

1. Fork or create a repository from this template.
2. Edit [`performance-target.json`](performance-target.json) for the target repository, project, platforms, and measurement policy.
3. Register dedicated self-hosted runners with `self-hosted`, `metric-test`, and the matching `Windows`, `Linux`, or `macOS` labels.
4. Create a protected `performance-lab` Environment. Require approval when personal or shared machines execute target code.
5. In **Settings → Pages**, select **GitHub Actions** as the source.
6. Run **Validate dashboard configuration**.
7. Run **Run performance benchmark** with **quick validation** enabled.
8. Review the artifact and Pages deployment before running the full configured benchmark.

No secret is needed for a public target. For a private target, create `TARGET_REPOSITORY_TOKEN` with fine-grained, read-only Contents access to that repository. Do not use an administrator token.

## Configuration

`performance-target.json` is the only target-specific file. Paths are relative to the checked-out target repository and may not contain parent traversal segments.

The default configuration profiles Sidebar Diagnostics and demonstrates all three operating systems. Set `schedule.enabled` to `true` only after every listed runner is available. Scheduled workflows execute code from the configured target ref, so use a protected branch, immutable tag, or commit.

## Workflows

| Workflow | Purpose |
|---|---|
| Validate dashboard configuration | Fast configuration validation on pushes and pull requests |
| Run performance benchmark | Manual single-platform benchmark with optional quick mode and ref override |
| Run scheduled performance benchmarks | Weekly configured platform matrix; disabled by default |
| Refresh performance report history | Daily Pages rebuild so expired artifacts disappear |

Performance workflows never run for pull requests. Target code executes only after a manual dispatch or an explicitly enabled default-branch schedule, and the reusable profiler runs inside the `performance-lab` Environment.

## Measurement guidance

Use fixed physical runners, power settings, workload, display topology, and application state. Compare runs from the same machine and operating system. Cross-machine results are descriptive, not regression evidence. A positive memory trend is a signal for deeper analysis rather than proof of a leak.

## Versioning

Reusable workflows are pinned to immutable DotNetPerformanceLab commit SHAs. Dependabot opens reviewable updates instead of silently following `main`. Replace development SHAs with an official major release after it is published.

## License

Licensed under the [MIT License](LICENSE).
