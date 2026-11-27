#!/usr/bin/env bash
# Formats C# files with Rider's formatter (JetBrains `jb cleanupcode`), using the rules in
# .editorconfig and <solution>.DotSettings, then adds the trailing commas StyleCop wants.
#
#   tools/format.sh            format every .cs file in the solution
#   tools/format.sh --changed  format only .cs files changed against main (committed or not)
#   tools/format.sh FILE...    format the given files
set -euo pipefail

cd "$(dirname "$0")/.."
dotnet tool restore > /dev/null

shopt -s nullglob
solutions=(*.slnx *.sln)
shopt -u nullglob
if [[ ${#solutions[@]} -ne 1 ]]; then
    echo "Expected one .slnx or .sln file in $(pwd), found ${#solutions[@]}." >&2
    exit 1
fi
solution="${solutions[0]}"

if [[ "${1:-}" == "--changed" ]]; then
    base="$(git merge-base HEAD main)"
    files=()
    while IFS= read -r file; do
        files+=("$file")
    done < <(
        { git diff --name-only --diff-filter=d "$base" -- '*.cs'
          git ls-files --others --exclude-standard -- '*.cs'; } | sort -u)
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No changed .cs files."
        exit 0
    fi
elif [[ $# -gt 0 ]]; then
    files=("$@")
else
    files=()
fi

if [[ ${#files[@]} -gt 0 ]]; then
    jb_include="$(IFS=';'; echo "${files[*]}")"
    format_include=(--include "${files[@]}")
else
    jb_include='**/*.cs'
    format_include=()
fi

echo "Reformatting with Rider's rules..."
dotnet jb cleanupcode "$solution" \
    --profile="Built-in: Reformat Code" \
    --include="$jb_include" \
    --exclude='**/Migrations/**;**/Generated/**;**/bin/**;**/obj/**' \
    --no-build \
    --verbosity=WARN

# "Reformat Code" only moves whitespace, so lists it splits over several lines are left
# without the trailing comma StyleCop requires; its SA1413 code fix adds them.
echo "Adding trailing commas (SA1413)..."
dotnet format analyzers "$solution" \
    --diagnostics SA1413 \
    --severity warn \
    ${format_include[@]+"${format_include[@]}"} \
    --exclude '**/Migrations/**' '**/Generated/**'
