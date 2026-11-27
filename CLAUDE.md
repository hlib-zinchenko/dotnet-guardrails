# CLAUDE.md

## Commands

```bash
tools/format.sh --changed   # format the .cs files changed against main
dotnet build                # analyzers run here; warnings are errors
dotnet test                 # xUnit v3 on Microsoft Testing Platform
```

## Code style (enforced by the build, not by review)

Enforced via `.editorconfig` + StyleCop + Sonar + `Hlibz.TypeRules.Analyzers`, with
`TreatWarningsAsErrors` in `Directory.Build.props`. Do not silence a rule to get green: fix the
code, or change the rule in `.editorconfig` with a comment explaining why.

- File-scoped namespaces, `using` directives outside the namespace.
- `var` is disallowed, always write the explicit type.
- 4-space indent, LF, UTF-8 without BOM, 100-char lines.
- **Don't format by hand** (no rewrapping lines to 100 chars, no re-chopping arguments): write the
  code, run `tools/format.sh --changed` (or `tools/format.sh <files>`; no argument = the whole
  solution), then `dotnet build`. The script runs Rider's formatter (`dotnet jb cleanupcode`, a
  local tool) with the wrap rules in `.editorconfig` + `Sample.slnx.DotSettings`, then
  `dotnet format analyzers --diagnostics SA1413` for the trailing commas it doesn't add.
  If the build still fails on layout, restructure instead of rewrapping: an argument too long
  for one line (SA1118) moves into a local; a ternary whose branch is a multi-line collection
  expression (SA1143) becomes `if`/`else`.
- Private fields `_camelCase`, async methods end in `Async`, interfaces start with `I`.
- A null-forgiving `!` needs a one-line comment above it starting `// !` that gives the reason.
- Comments on members are XML docs (`/// <summary>`), not `//`.
- Time comes from `IClock`; `DateTime.Now`/`UtcNow` are banned (`BannedSymbols.txt`).
- Entities have private setters, read-only collections and identity equality; strongly-typed
  ids are immutable with value equality (`typerules.*` in `.editorconfig`).
- Package versions live only in `Directory.Packages.props`.

## Tests

One test project per source project under `tests/`, named `Subject_WithCondition_ExpectedOutcome`.
