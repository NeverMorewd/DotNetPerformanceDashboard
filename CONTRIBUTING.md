# Contributing

Keep the repository target-agnostic except for the example `performance-target.json`. Changes must preserve the fork workflow, avoid executing pull-request code on self-hosted runners, and pin reusable workflows and third-party actions to reviewed versions or immutable commits.

Before opening a pull request, run:

```powershell
./scripts/Test-TargetConfiguration.ps1
```

Workflow changes should be validated with quick mode before a full benchmark. Never commit generated reports, access tokens, runner work directories, or target application binaries.
