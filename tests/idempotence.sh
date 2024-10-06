#!/usr/bin/env bash
set -euo pipefail

# Run against a disposable snap-capable host, with the usual Ansible CLI options.
export ANSIBLE_ROLES_PATH="$(cd "$(dirname "$0")/../.." && pwd)${ANSIBLE_ROLES_PATH:+:$ANSIBLE_ROLES_PATH}"
playbook="$(cd "$(dirname "$0")" && pwd)/test.yml"
ansible-playbook "$playbook" "$@"
output=$(ANSIBLE_NOCOLOR=1 ansible-playbook "$playbook" "$@")
printf '%s\n' "$output"
printf '%s\n' "$output" | python3 -c '
import re, sys
text = sys.stdin.read()
recap = text.split("PLAY RECAP", 1)
if len(recap) != 2:
    sys.exit("Missing Ansible recap")
counts = re.findall(r"\bchanged=(\d+)", recap[1])
if not counts or any(int(count) for count in counts):
    sys.exit("Second run was not idempotent or had no hosts")
'
