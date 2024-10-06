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
| `multipass_settings` | `{}` | Mapping of settings to manage. Omitted settings are left unchanged. |

The supported mapping keys are `client.primary-name` (string, including `""` to disable the primary instance), `local.bridged-network` (string), `local.privileged-mounts` (YAML boolean), and `local.passphrase` (string). The primary name belongs to the selected **client user**; the other settings belong to the daemon. Multipass validates setting values. See the [settings reference](https://canonical.com/multipass/docs/stable/reference/settings/) for their effects. GUI-only settings cannot be configured with the current CLI, and Windows-only and instance/snapshot settings are outside this Linux role's scope.

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
        multipass_settings:
          client.primary-name: primary
          local.bridged-network: eno1
          local.privileged-mounts: false
          # local.passphrase: "{{ vault_multipass_passphrase }}"
```

## Testing

Run `ansible-playbook -i tests/inventory tests/test.yml --syntax-check`. On a disposable, snap-capable Debian-family host, run `tests/idempotence.sh -i <inventory>` with suitable privilege escalation. The script applies the role twice and checks idempotence for readable settings; it installs software on the target.

## License

BSD-3-Clause.
