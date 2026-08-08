# nix-config

NixOS flake for two graphical clients and a reusable headless server. Host
files contain hardware and machine-specific decisions; profiles compose shared
behavior; modules implement individual features.

## Systems

| Configuration | Role | Highlights |
| --- | --- | --- |
| `framework` | Laptop client | Framework AMD hardware, niri/DMS, Sway fallback, printing, power profiles |
| `workstation` | Desktop client | RDNA4 graphics, disko, libvirt, Syncthing, remote SSH |
| `server` | Incus server | Generic UEFI layout, LTS kernel, clustered virtualization, key-only SSH |

The generic server expects filesystems labeled `nixos` and `ESP`. Replace
`hosts/server/hardware.nix` with generated hardware configuration before a
physical deployment when those assumptions do not match.

## Structure

```text
.
├── flake.nix                 # inputs, hosts, exported modules, checks
├── hosts/                    # hardware and host-specific overrides
│   ├── framework/
│   ├── workstation/
│   └── server/
├── profiles/
│   ├── nixos/
│   │   ├── base.nix          # common system policy
│   │   ├── client.nix        # graphical workstation composition
│   │   └── server.nix        # headless composition
│   └── home/client.nix       # graphical Home Manager composition
├── modules/
│   ├── nixos/                # focused operating-system features
│   └── home/                 # focused user-environment features
├── docs/
│   └── incus-ha.md           # cluster, storage, fencing, and maintenance runbook
├── lib/                      # shared data and helpers
├── secrets/                  # sops-encrypted material
├── justfile                  # common maintenance commands
└── treefmt.nix               # repository formatter
```

The `r` path record passed through `specialArgs` provides stable paths such as
`r.profilesNixos`, `r.modulesNixos`, and `r.modulesHome`. Modules do not depend
on fragile chains of `../..` imports.

## Profile policy

The base profile provides:

- Lix with pinned signed binary caches and sandboxed builds;
- a default-deny NixOS firewall and low-overhead kernel hardening;
- authenticated `doas` administration with no passwordless root rules;
- zram, periodic store optimization, garbage collection, SSD trim, and bounded
  journal storage;
- automatic builds from the published host flake. Successful updates are made
  the next boot generation but are neither activated nor rebooted automatically.

The client profile adds niri, DankMaterialShell, ly, PipeWire, Firefox policy,
the desktop keyring, Steam, Flatpak, rootless Podman, and Home Manager. Podman
provides Docker-compatible commands and a Docker socket, avoiding a second
container daemon.

The server profile stays headless, uses the LTS kernel, disables large local
documentation and core dumps, and enables hardened OpenSSH with fail2ban. It
also runs `incus-lts` with AppArmor, nftables, soft daemon restarts, and a
three-voter cluster policy.

## Security defaults

- SSH permits public-key authentication only. Root login, X11 forwarding,
  agent forwarding, tunnels, and TCP forwarding are disabled by default.
- The workstation explicitly enables TCP forwarding for development tunnels.
- The Framework laptop does not run an SSH server.
- Only root is a trusted Nix user. Trusted Nix users can gain root through
  custom substituters, so membership is intentionally not granted to `wheel`.
- Desktop polkit uses upstream scoped policies and authentication defaults.
- Syncthing exposes transfer/discovery ports, not its management UI.
- The Incus API is closed until exact management interfaces or CIDRs are set.
- Automatic Incus healing requires explicit shared-storage and fencing
  confirmations.
- PAM U2F is available as `nighthawk.security.u2f.enable` but remains disabled
  until a credential mapping has been provisioned.

Secrets use sops-nix and an age key at
`~/.config/sops/age/keys.txt`. See `secrets/ReadMe.md` and `.sops.yaml`.

## Development environment

Enter the repository shell directly:

```console
nix develop
```

With direnv installed, run `direnv allow` once; `.envrc` then loads the same
shell automatically. It includes nixd, nil, nixfmt, statix, deadnix, actionlint,
shellcheck, sops, age, `nh`, and `nix-output-monitor`. Client container tooling
also includes the Incus remote-management CLI.

Common commands:

```console
just fmt
just lint
just check
just eval framework
just build server
just switch workstation
```

The default Home Manager development set contains Nix and shell tooling. Larger
tool groups are opt-in:

```nix
nighthawk.development = {
  enable = true;
  containers.enable = true;
  cloud.enable = true;
  kubernetes.enable = true;
  languages.enable = true;
};
```

Project-specific language versions should normally live in each project's
flake or dev shell. The global language bundle is provided for projects that do
not yet have one.

Optional graphical bundles follow the same pattern:

```nix
nighthawk.desktopApps = {
  enable = true;
  cad.enable = true;
  minecraft.enable = true;
  peerToPeer.enable = true;
  remoteAccess.enable = true;
  teams.enable = true;
};
```

## Installation and deployment

Client rebuild:

```console
sudo nixos-rebuild switch --flake .#framework
```

Remote server build and activation:

```console
nixos-rebuild switch --flake .#server \
  --target-host nighthawk@server \
  --use-remote-sudo
```

The server declares immutable users and no password hashes. Confirm that the
public key in `lib/keys/id_rsa.pub` is available before deployment.

Incus needs a unique static management address and host name for every cluster
member. The generic server intentionally does not guess those values or store
cluster join tokens. Follow [the Incus HA runbook](docs/incus-ha.md) to create a
three-member control plane, choose shared storage, configure fencing, and expose
a highly available API endpoint.

The workstation uses disko. Replace `/dev/disk/by-id/REPLACE-ME` in
`hosts/workstation/disko.nix` before running any disko operation.

To add a host:

1. Create `hosts/<name>/default.nix` and a hardware module.
2. Import either `r.profilesNixos + /client.nix` or
   `r.profilesNixos + /server.nix`.
3. Add the host to `nixosConfigurations` in `flake.nix`.
4. Run `just eval <name>` and `just check`.

## Validation

`nix flake check` verifies formatting and evaluates every NixOS toplevel without
building the full system closures. CI repeats that evaluation on every pull
request and push to `main`, then verifies the pinned Lix package can be built or
substituted.

Review NixOS state-version changes separately from package upgrades. Existing
`system.stateVersion` and `home.stateVersion` values intentionally remain at
`24.05`.
