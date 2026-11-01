# dotnet-guardrails

A strict, copy-able .NET setup: analyzers, style rules, type-shape rules and banned APIs that
fail the build instead of waiting for code review. Built for humans and AI agents alike - an
agent that edits code here gets a compiler error, not a lecture, when it drifts.

## What's in the box

| File | What it enforces |
|---|---|
| `Directory.Build.props` | .NET 10, nullable, `AnalysisMode=All`, `TreatWarningsAsErrors`, analyzer packages for every project |
| `Directory.Packages.props` | Central package versions (analyzers + xUnit v3) |
| `.editorconfig` | Formatting, naming, explicit types (no `var`), StyleCop + Sonar + CA tuning, xUnit rules, and the `typerules.*` rule sets |
| `tests/.editorconfig` | Relaxations for test code (underscored names, helper entities) |
| `BannedSymbols.txt` | `DateTime.Now`/`UtcNow` etc. banned in favour of an injected clock |
| `.gitattributes`, `global.json` | LF everywhere; xUnit v3 on Microsoft Testing Platform |
| `CLAUDE.md` | The rules above, written for an AI agent |
| `src/Sample.Core`, `tests/Sample.Core.Tests` | A tiny kernel (`Entity<TId>`, `IEntityId`, `IClock`) so every rule has something to bite on |

Analyzers: [StyleCop](https://github.com/DotNetAnalyzers/StyleCopAnalyzers),
[SonarAnalyzer](https://github.com/SonarSource/sonar-dotnet),
[Nullable.Extended.Analyzer](https://github.com/Kampfkarren/Nullable.Extended.Analyzer) (every `!` needs a `// !` reason),
[BannedApiAnalyzers](https://github.com/dotnet/roslyn-analyzers),
[Hlibz.TypeRules.Analyzers](https://github.com/hlib-zinchenko/Hlibz.TypeRules.Analyzers).
For EF Core, add [Hlibz.EntityFrameworkCore.ModelRules](https://github.com/hlib-zinchenko/Hlibz.EntityFrameworkCore.ModelRules).

## Adopting it in an existing repo

1. Copy `Directory.Build.props`, `Directory.Packages.props` (merge versions), `.editorconfig`,
   `tests/.editorconfig`, `BannedSymbols.txt`, `.gitattributes`, `global.json`.
2. In `.editorconfig`, repoint the `typerules.*.match` lines at your own base types, and update
   the message in `BannedSymbols.txt` to your clock abstraction.
3. Build. Expect a wall of errors; fix by rule, or lower a rule's severity *deliberately* in
   `.editorconfig` with a comment saying why.
4. Add the sections of `CLAUDE.md` that apply to your agent instructions.

## Try it

```bash
dotnet build   # clean
dotnet test
```

Break something on purpose (a `var`, a public setter on an entity, `DateTime.UtcNow`) and watch
the build fail.

## License

MIT
