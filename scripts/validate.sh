#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

expected="$(tail -n +2 scripts/questions.index | wc -l | tr -d ' ')"
actual="$(find . -maxdepth 1 -type d -name 'Question-*' | wc -l | tr -d ' ')"
[[ "$actual" == "$expected" ]] || {
  echo "Expected $expected question directories, found $actual" >&2
  exit 1
}

bash -n scripts/*.sh
find . -maxdepth 2 -type f -name '*.bash' -print0 |
  while IFS= read -r -d '' file; do
    bash -n "$file"
  done

while IFS='|' read -r number directory level source; do
  [[ "$number" == "number" ]] && continue
  for file in LabSetUp.bash Questions.bash SolutionNotes.bash; do
    [[ -f "$directory/$file" ]] || {
      echo "Missing $directory/$file" >&2
      exit 1
    }
  done
  bash scripts/print-question.sh "$number" >/dev/null
  bash scripts/print-solution.sh "$number" >/dev/null
done < scripts/questions.index

bash scripts/setup-question.sh 01 >/dev/null
bash scripts/setup-question.sh 06 >/dev/null
bash scripts/setup-question.sh 16 >/dev/null
bash scripts/setup-question.sh 22 >/dev/null
source scripts/aliases.sh >/dev/null

alias q1 >/dev/null
alias q27 >/dev/null
alias qlist >/dev/null
alias qrandom >/dev/null

test -f /tmp/cks-prep/q01-kubeconfig
(cd /tmp/cks-prep/q06/binaries && sha512sum -c ../verified.sha512 >/dev/null)
test -f /tmp/cks-prep/q16/Dockerfile
test -f /tmp/cks-prep/q22/02-leaked-env.yaml

echo "Validated $actual question directories and all shell renderers."
