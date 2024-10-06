<!-- bmad:context -->
<!-- Verified 2026-11-10 against a3c098fc7e11918cd3c550938f1c4fac856068ec and the current working tree. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## ansible-role-multipass

An Ansible role that installs and configures Multipass on Debian-family hosts. See `README.md` for supported settings, their security implications, and testing.

## Policy

- Use Conventional Commits for commit messages.

## Running and verifying

- For the syntax check, set `ANSIBLE_ROLES_PATH=..` as in `.github/workflows/ci.yml` so Ansible can find this role.
- Run `tests/idempotence.sh` only against a disposable, snap-capable host; it installs software and applies the role twice.

<!-- /bmad:context -->
