#!/usr/bin/env bash

cks_repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

alias qlist="bash '$cks_repo_root/scripts/run-question.sh' list"
alias qrandom="bash '$cks_repo_root/scripts/run-question.sh' random"

for cks_question_number in $(seq 1 27); do
  alias "q${cks_question_number}=bash '$cks_repo_root/scripts/run-question.sh' ${cks_question_number}"
done

unset cks_question_number

echo "CKS aliases loaded: q1 through q27, qlist, and qrandom"
