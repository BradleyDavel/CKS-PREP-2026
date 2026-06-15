#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

list_questions() {
  printf '%-12s %-42s %-8s %s\n' "QUESTION" "TOPIC" "LEVEL" "SOURCE"
  while IFS='|' read -r number directory level source; do
    [[ "$number" == "number" ]] && continue
    printf '%-12s %-42s %-8s %s\n' "$number" "${directory#Question-* }" "$level" "$source"
  done < scripts/questions.index
}

if [[ $# -lt 1 ]]; then
  echo "Usage: bash scripts/run-question.sh <number|folder|list|random>" >&2
  exit 1
fi

case "$1" in
  list|--list|-l)
    list_questions
    exit 0
    ;;
  random)
    selection="$(tail -n +2 scripts/questions.index | awk -F'|' 'BEGIN{srand()} {a[NR]=$2} END{print a[int(1+rand()*NR)]}')"
    ;;
  *)
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      padded="$(printf '%02d' "$((10#$1))")"
      selection="$(awk -F'|' -v n="$padded" '$1 == n {print $2}' scripts/questions.index)"
    else
      selection="$*"
    fi
    ;;
esac

if [[ -z "${selection:-}" || ! -d "$selection" ]]; then
  echo "Question '$*' was not found. Run: bash scripts/run-question.sh list" >&2
  exit 1
fi

setup="$selection/LabSetUp.bash"
question="$selection/Questions.bash"
solution="$selection/SolutionNotes.bash"

[[ -f "$setup" ]] || { echo "Missing $setup" >&2; exit 1; }
[[ -f "$question" ]] || { echo "Missing $question" >&2; exit 1; }

echo "==> Preparing $selection"
bash "$setup"

echo
echo "==> Question"
bash "$question"

echo
if [[ -f "$solution" ]]; then
  echo "Reveal the solution with:"
  printf '  bash %q\n' "$solution"
fi
