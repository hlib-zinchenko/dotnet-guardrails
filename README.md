# dotnet-guardrails

A strict, copy-able .NET setup: analyzers, style rules, type-shape rules and banned APIs that
fail the build instead of waiting for code review. Built for humans and AI agents alike - an
agent that edits code here gets a compiler error, not a lecture, when it drifts.

## Where it comes from

This isn't a one-off config. It's the setup I've carried from project to project and tightened each time:

- **2018-2023.** Started with StyleCop, so style stopped being a review topic.
- **2024.** Added nullable reference types and treated warnings as errors, so the compiler said no instead of a reviewer.
- **2024-2025.** Reworked the setup together with another developer, on a larger codebase.
- **2026, my startup.** Shaping it now for a codebase where AI agents write most of the code: banned APIs, my own [TypeRules](https://github.com/hlib-zinchenko/Hlibz.TypeRules.Analyzers) and [ModelRules](https://github.com/hlib-zinchenko/Hlibz.EntityFrameworkCore.ModelRules), and a `CLAUDE.md` with the same rules for the agent.

It will keep changing. When a rule stops earning its place or a new one starts to, this repo changes first.

## What it's for

Code review is for architecture, logic and organization: does this belong here, does it do the right thing, is it shaped well. It was never meant for catching a missing `sealed`, a stray `var` or a `DateTime.Now`. With rules this strict the build catches those first, so the reviewer only sees code that already follows the house style and can spend the review on what a tool can't judge.

## What's in the box

| File | What it enforces |
|---|---|
| `Directory.Build.props` | .NET 11, nullable, `AnalysisMode=All`, `TreatWarningsAsErrors`, analyzer packages for every project |
| `Directory.Packages.props` | Central package versions (analyzers + xUnit v3) |
| `.editorconfig` | Formatting, naming, explicit types (no `var`), StyleCop + Sonar + CA tuning, xUnit rules, and the `typerules.*` rule sets |
| `tests/.editorconfig` | Relaxations for test code (underscored names, helper entities) |
| `BannedSymbols.txt` | `DateTime.Now`/`UtcNow` etc. banned in favour of an injected clock |
| `.gitattributes`, `global.json` | LF everywhere; the .NET 11 SDK; xUnit v3 on Microsoft Testing Platform |
| `Sample.slnx.DotSettings` | Rider's wrap rules (team-shared layer), so the IDE and the command line wrap the same way |
| `tools/format.sh`, `.config/dotnet-tools.json` | Formatting as a command: Rider's formatter (`jb cleanupcode`, a local tool) plus StyleCop's trailing-comma fix |
| `CLAUDE.md` | The rules above, written for an AI agent |
| `src/Sample.Core`, `tests/Sample.Core.Tests` | A tiny kernel (`Entity<TId>`, `IEntityId`, `IClock`) so every rule has something to bite on |

Analyzers: [StyleCop](https://github.com/DotNetAnalyzers/StyleCopAnalyzers),
[SonarAnalyzer](https://github.com/SonarSource/sonar-dotnet),
[Nullable.Extended.Analyzer](https://github.com/Kampfkarren/Nullable.Extended.Analyzer) (every `!` needs a `// !` reason),
[BannedApiAnalyzers](https://github.com/dotnet/roslyn-analyzers),
[Hlibz.TypeRules.Analyzers](https://github.com/hlib-zinchenko/Hlibz.TypeRules.Analyzers).
For EF Core, add [Hlibz.EntityFrameworkCore.ModelRules](https://github.com/hlib-zinchenko/Hlibz.EntityFrameworkCore.ModelRules).

## Formatting is a command, not a chore

Analyzers say *that* a line is wrong; they don't lay code out. Rewrapping lines to 100 characters
by hand is wasted effort for a person and wasted tokens for an agent, so layout belongs to a
formatter:

```bash
tools/format.sh --changed   # the .cs files changed against main
tools/format.sh             # the whole solution
dotnet build
```

The script runs Rider's own formatter from the command line (`dotnet jb cleanupcode`, the free
JetBrains.ReSharper.GlobalTools, pinned as a local tool) with the rules in `.editorconfig` and
`Sample.slnx.DotSettings`, then `dotnet format analyzers --diagnostics SA1413`, because Rider's
"Reformat Code" splits lists over several lines without adding the trailing comma StyleCop wants.
`dotnet format` alone isn't enough: Roslyn's formatter never wraps long lines.

The wrap rules are chosen to agree with StyleCop: ternaries and chained calls are chopped only
when too long (chopping them always trips SA1118/SA1143), and braces stay on their own line
(SA1500). A few lines no setting can save, such as one argument longer than a line; restructure
those (a local variable, an `if`/`else`) rather than wrapping by hand.

## Adopting it in an existing repo

1. Copy `Directory.Build.props`, `Directory.Packages.props` (merge versions), `.editorconfig`,
   `tests/.editorconfig`, `BannedSymbols.txt`, `.gitattributes`, `global.json`,
   `.config/dotnet-tools.json` (merge tools) and `tools/format.sh`.
2. Copy `Sample.slnx.DotSettings` as `<YourSolution>.slnx.DotSettings` (or `.sln.DotSettings`) -
   Rider only reads the file named after the solution.
3. In `.editorconfig`, repoint the `typerules.*.match` lines at your own base types, and update
   the message in `BannedSymbols.txt` to your clock abstraction.
4. Run `tools/format.sh`, then build. Expect a wall of errors; fix by rule, or lower a rule's
   severity *deliberately* in `.editorconfig` with a comment saying why. Commit the reformat on
   its own and list it in `.git-blame-ignore-revs`.
5. Add the sections of `CLAUDE.md` that apply to your agent instructions.

## Try it

```bash
tools/format.sh   # no changes
dotnet build      # clean
dotnet test
```

Break something on purpose (a `var`, a public setter on an entity, `DateTime.UtcNow`) and watch
the build fail.

## License

MIT
