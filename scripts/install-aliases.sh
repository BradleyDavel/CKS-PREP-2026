#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shell_file="${HOME}/.bashrc"
source_line="source '$repo_root/scripts/aliases.sh'"

touch "$shell_file"

if ! grep -Fqx "$source_line" "$shell_file"; then
  printf '\n# CKS-PREP-2026 question aliases\n%s\n' "$source_line" >> "$shell_file"
  echo "Added CKS aliases to $shell_file"
else
  echo "CKS aliases are already configured in $shell_file"
fi

echo "Run this now, or open a new terminal:"
echo "  source '$shell_file'"
