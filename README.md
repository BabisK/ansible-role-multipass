# Ansible role: Multipass

Installs the Multipass snap and optionally configures its global CLI settings on Debian-family Linux hosts. Multipass uses QEMU on Linux; this role does not install or select the obsolete LXD or libvirt drivers, or manage instances.

## Requirements

- Ansible Core 2.15 or newer and the `community.general` collection: `ansible-galaxy collection install -r collections/requirements.yml`.
- A Debian-family host with systemd, snap support, access to the Snap Store, and a working QEMU/KVM environment. Running VMs requires appropriate virtualization support.
- Privilege escalation to root; configuring a client setting for another user also requires escalation to that user.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `multipass_snap_channel` | `latest/stable` | Snap channel to install and track. |
| `multipass_client_user` | `root` | Existing target user whose client settings are managed. This is independent of the SSH user. |
| `multipass_client_primary_name` | `null` | Primary instance name for the selected client user; `""` disables it. |
| `multipass_local_bridged_network` | `null` | Network interface used for bridged instances. |
| `multipass_local_privileged_mounts` | `null` | YAML boolean controlling privileged mounts. |
| `multipass_local_passphrase` | `null` | Write-only authentication passphrase. |

Settings left as `null` are not managed. The primary name belongs to the selected **client user**; the other settings belong to the daemon. Multipass validates setting values. See the [settings reference](https://canonical.com/multipass/docs/stable/reference/settings/) for their effects. GUI-only settings cannot be configured with the current CLI, and Windows-only and instance/snapshot settings are outside this Linux role's scope.

The former `multipass_settings` mapping is no longer supported. Replace each mapping entry with its corresponding individual variable above.

The passphrase is write-only: Multipass reports whether one exists, not its value. If supplied, the role sets it on every normal run and reports a change; omit it on later runs if that is undesirable. Store it with Ansible Vault. Ansible output is censored, but the value is briefly visible in the target process arguments to privileged local observers. An empty string is passed through to Multipass. Setting a passphrase grants anyone who knows it control of Multipass.

In check mode, the role compares readable settings when Multipass is already installed. On a fresh host it reports configuration as pending because the client is not yet available. The passphrase is always reported as a prospective change when supplied.

The former `mutlipass_backend` variable is no longer used. Linux now supports QEMU as its driver; existing instances on obsolete drivers are not migrated by this role.

## Example

```yaml
- hosts: workstations
  roles:
    - role: ansible-role-multipass
      vars:
        multipass_client_user: alice
        multipass_client_primary_name: primary
        multipass_local_bridged_network: eno1
        multipass_local_privileged_mounts: false
        # multipass_local_passphrase: "{{ vault_multipass_passphrase }}"
```

## Testing

Run `ansible-playbook -i tests/inventory tests/test.yml --syntax-check`. On a disposable, snap-capable Debian-family host, run `tests/idempotence.sh -i <inventory>` with suitable privilege escalation. The script applies the role twice and checks idempotence for readable settings; it installs software on the target.

## Releases

Use Conventional Commits in pull request titles and commits. Release-please opens a release pull request when features, fixes, performance improvements, reverts, or breaking changes are ready. Merging it creates a version tag and a GitHub release. Other commit types do not normally trigger a release.

The release workflow uses a GitHub App installed on this repository, configured with the `RP_APP_CLIENT_ID` variable and `RP_APP_PRIVATE_KEY` secret. Do not manually edit the release manifest or `CHANGELOG.md`. PR-title and commit-message checks are advisory; maintainers should review them before merging. When squash merging, check the resulting commit title and body: conventional commit text in the body can affect release notes and version selection.

## License

BSD-3-Clause.
