![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat-square&logo=NixOS&logoColor=white)
![Flakes Enabled](https://img.shields.io/badge/Flakes-Enabled-blueviolet.svg?style=flat-square)
![Home Manager](https://img.shields.io/badge/Home%20Manager-Managed-orange.svg?style=flat-square)
![sops-nix](https://img.shields.io/badge/Secrets-sops--nix%20%2B%20age-critical.svg?style=flat-square)
![Disko](https://img.shields.io/badge/Storage-Disko%20%2B%20ZFS-9cf.svg?style=flat-square)
![License](https://img.shields.io/badge/License-GPL--2.0-lightgrey.svg?style=flat-square)

# nixlab

A single Nix flake that defines five machines: two workstations and a three-node Dell PowerEdge rack. Kernels, ZFS pool topology, services, firewall rules, user dotfiles, and encrypted secrets all live in this repository — there is no manual configuration on any host.

**Flake:** `x86_64-linux` only · nixpkgs `nixos-unstable` (with `nixos-25.11` available as `pkgs-stable`) · Home Manager · Disko · sops-nix

---

## Fleet

| Host | Hardware | Role modules | What it actually runs |
| :--- | :--- | :--- | :--- |
| **`navi`** | Custom AMD desktop | `desktop-node` + `navi-desktop` | Primary workstation. Plasma 6 (SDDM) and Hyprland, CachyOS LTS kernel, Steam/gaming, libvirt, emulation, Flatpak, CoreCtrl for AMD tuning. Dispatches heavy builds to `r820`. |
| **`oryx`** | System76 laptop | `desktop-node` + `system76-laptop` + `nixos-hardware.system76` | Portable workstation. Same desktop stack; NVIDIA PRIME sync, System76 firmware/power daemons, `system76-scheduler`. |
| **`r730`** | Dell PowerEdge R730 | `server-core` + `storage-node` + `dell-poweredge` | ZFS host on `r730pool`, kernel pinned to 6.1, Docker enabled. Staged for AI/GPU work — see [Staged, not active](#staged-not-active). |
| **`r730xd`** | Dell PowerEdge R730xd (24-bay) | `server-core` + `media-node` + `storage-node` + `dell-poweredge` | The workhorse. Media stack, Vaultwarden, Prometheus + Grafana, headless NVIDIA for Jellyfin transcoding, `mediapool`. |
| **`r820`** | Dell PowerEdge R820 (quad-socket) | `server-core` + `dell-poweredge` | PostgreSQL + pgAdmin, libvirt, and the distributed Nix build target for both workstations (`maxJobs = 32`). |

### Network

Static addressing on `eno1`, defined once in the `fleet` attribute set in `flake.nix` and consumed by each host — the table is the single source of truth, so a host's address and its `fleet` entry cannot drift.

| Host | Address | ZFS pool |
| :--- | :--- | :--- |
| `r730xd` | `192.168.1.2` | `mediapool` |
| `r730` | `192.168.1.3` | `r730pool` |
| `r820` | `192.168.1.4` | — (hardware RAID) |
| gateway / DNS | `192.168.1.1` | — |

`navi` and `oryx` are DHCP clients and reach the rack over Tailscale when off-LAN. IPv6 is disabled fleet-wide on servers.

---

## Layout

```text
nixlab/
├── flake.nix                     # inputs, the `fleet` table, mkHost, per-host outputs
├── flake.lock
├── .sops.yaml                    # age recipients: your user key + all five host keys
├── .github/workflows/ci.yml      # per-host dry-run build matrix + nix flake check
├── hosts/
│   ├── navi/                     # configuration + hardware-configuration
│   ├── oryx/
│   ├── r730/                     # + disko-config.nix (4 × 2-disk mirror vdevs)
│   ├── r730xd/                   # + disko-config.nix (3 × 8-disk raidz2 vdevs)
│   └── r820/
├── modules/
│   ├── roles/                    # composed baselines — see below
│   ├── features/                 # opt-in services, one concern per file
│   └── hardware/                 # machine-specific quirks (GRUB modes, PRIME, iDRAC fans)
├── users/aljam/
│   ├── nixos.nix                 # system-level account, groups, password secret
│   ├── home.nix                  # CLI baseline: fish, git, neovim, packages
│   ├── home-gui.nix              # desktop-only: themes, kitty, obs, GUI apps
│   └── modules/{core,desktop}/
└── secrets/secrets.yaml          # sops-encrypted, one file, all hosts
```

### How a host is composed

`mkHost` in `flake.nix` gives every machine the same base, then layers on role and feature modules:

```
hosts/<name>/configuration.nix
  └─ modules/roles/common.nix          always: hostname, locale, SSH, sops, nix.settings, GC
  └─ modules/roles/{desktop-node|server-core}.nix
       └─ modules/features/*.nix       audio, hyprland, jellyfin, arr-stack, …
  └─ modules/hardware/<machine>.nix
  └─ users/aljam/{nixos.nix,home.nix}
```

Modules receive `hostname`, `domains`, `subnets`, and `fleet` through `specialArgs` (and the same set through `home-manager.extraSpecialArgs`), so no module hardcodes a hostname or an IP literal.

**Roles**

| Module | Applies to | Provides |
| :--- | :--- | :--- |
| `common.nix` | all five | `stateVersion`, timezone/locale, substituters, SSH (keys only, `AllowUsers`), sops, fail2ban, `execWheelOnly`, weekly GC + store optimisation, base CLI tools |
| `server-core.nix` | the rack | static networking, nftables, Podman (with Docker socket), smartd, node-exporter |
| `desktop-node.nix` | `navi`, `oryx` | CachyOS LTS kernel, NetworkManager, Tailscale, KDE Connect, audio/bluetooth/graphics/Hyprland, gaming, emulation, Flatpak, NAS mount, remote builder |
| `storage-node.nix` | `r730`, `r730xd` | ZFS weekly scrub + sanoid snapshots |
| `media-node.nix` | `r730xd` | the `media` group, Jellyfin, arr-stack, torrents, Vaultwarden, ytdl-sub, homepage-dashboard |

---

## Services

All on `r730xd` unless noted. Everything currently binds LAN addresses over plain HTTP — see [Known gaps](#known-gaps).

| Service | Port | Notes |
| :--- | :--- | :--- |
| Jellyfin | 8096 (default) | NVENC via `nvidia-headless.nix` |
| Sonarr / Radarr | 8989 / 7878 | `media` group, API keys from sops |
| Prowlarr / Bazarr / Lidarr / Readarr | defaults | |
| Shoko | 8111 | AniDB metadata |
| Jellyseerr | 5055 | |
| Audiobookshelf | 13378 | |
| Autobrr | 7474 | IRC announce filtering |
| qBittorrent (nox) | 8080 web / 6881 peer | container backend is Podman |
| Vaultwarden | 8222 | |
| homepage-dashboard | 8082 (default) | `allowedHosts` set to `home.derezzed.info` |
| Prometheus | 9090 | scrapes node-exporter on all servers |
| Grafana | 3000 | admin key from sops |
| node-exporter | 9100 | firewalled to `192.168.1.2` only |
| PostgreSQL / pgAdmin | 5432 / 5050 | **`r820`** — 5432 scoped to `eno1`, scram-sha-256 |
| Ollama / Open WebUI | 11434 / 8085 | **`r730`** — staged, not enabled |

---

## Storage

Both ZFS hosts are provisioned declaratively with [Disko](https://github.com/nix-community/disko), so a bare-metal reinstall reproduces partitioning, pool topology, and datasets with no manual `zpool create`.

**`r730` — `r730pool`:** four 2-disk mirror vdevs (8 disks), datasets `root` → `/`, `nix` → `/nix`, `home` → `/home`.

**`r730xd` — `mediapool`:** three 8-disk raidz2 vdevs (24 disks), datasets `root` → `/`, `media` → `/mnt/media`. ARC capped at 64 GiB via `zfs.zfs_arc_max`.

Both use `compression = zstd`, `atime = off`, and a dual-ESP layout (`/boot`, `/boot2`) mirrored across the first two disks. Weekly scrubs Sunday 02:00; sanoid snapshots via `storage-node`.

---

## Secrets

One `sops`-encrypted file, `secrets/secrets.yaml`, encrypted to your user key plus the age-converted SSH host key of all five machines. Each host decrypts at activation with `/etc/ssh/ssh_host_ed25519_key` — nothing depends on a user keyring being unlocked.

| Key | Consumer |
| :--- | :--- |
| `aljam_password` | user login / sudo (`neededForUsers = true`) |
| `sonarr_api_key`, `radarr_api_key` | Recyclarr |
| `autobrr_api_key` | Autobrr |
| `grafana-secret-key` | Grafana |
| `pgadmin_password` | pgAdmin |
| `alertmanager_smtp_password` | Alertmanager (not yet wired) |
| `restic-password` | reserved — see [Known gaps](#known-gaps) |

```bash
sops secrets/secrets.yaml               # edit
sops updatekeys secrets/secrets.yaml    # after adding a host to .sops.yaml
```

> `users.mutableUsers = false` is set fleet-wide, so passwords come **only** from `hashedPasswordFile`. If a host's SSH host key is ever regenerated it can no longer decrypt `aljam_password`, which means no console login and no `sudo` on that host. Re-run `sops updatekeys` and rebuild before rebooting after any host-key change.

---

## Usage

### Requirements

Nix with flakes enabled, and `git`:

```bash
experimental-features = nix-command flakes
```

### Build and switch

```bash
sudo nixos-rebuild switch --flake .#navi
```

### Check before you deploy

```bash
nix flake check                                                    # eval every host
nix build --dry-run '.#nixosConfigurations.r730xd.config.system.build.toplevel'
nixos-rebuild build --flake .#r730xd && nvd diff-closure /run/current-system result
```

`nvd` is in the base package set, so closure diffs work on every host.

### Deploy to the rack

```bash
nixos-rebuild switch --flake .#r730xd --target-host aljam@192.168.1.2 --use-remote-sudo
```

Both workstations use `r820` as a distributed builder (`nix.settings.trusted-users` includes `aljam` there), so large rebuilds are offloaded automatically. This relies on root's SSH key at `/root/.ssh/id_ed25519` on the client.

### First install on new hardware

```bash
# from the NixOS installer, with the flake available
sudo nix run github:nix-community/disko -- --mode disko --flake .#r730xd
sudo nixos-install --flake .#r730xd
```

Then convert the new host key and add it to `.sops.yaml`:

```bash
ssh-keyscan -t ed25519 <host> | ssh-to-age
sops updatekeys secrets/secrets.yaml
```

### Formatting and linting

```bash
nix run nixpkgs#nixfmt-rfc-style -- .
nix run nixpkgs#statix -- check
nix run nixpkgs#deadnix
nix run nixpkgs#actionlint            # validates .github/workflows/
```

### CI

`.github/workflows/ci.yml` runs `nix flake check` plus a `nix build --dry-run` matrix across all five hosts on every push and PR, so an eval error is caught per-host rather than as a single opaque failure.

---

## Staged, not active

Present in the tree but intentionally not imported. Enabling any of these needs the listed prerequisites.

| Module | Status |
| :--- | :--- |
| `modules/roles/ai-node.nix` | Ollama + Open WebUI for the Tesla P40s in `r730`. Needs `acceleration = "cuda"`, `nixpkgs.config.cudaSupport`, and `nvidia-container-toolkit` re-enabled — expect a long from-source rebuild. |
| `modules/features/nvidia-headless.nix` (on `r730`) | Commented out alongside `ai-node`. `r730` still installs `cudatoolkit` and `linuxPackages.nvidia_x11`; note the latter targets the default kernel while the host pins `linuxPackages_6_1`. |
| `modules/roles/mail-node.nix` | Imported nowhere. Needs `mailserver.nixosModules.mailserver` added to the module list and `smtp_relay_password` + `mail_password_aljam` added to `secrets.yaml`. |

---

## Known gaps

Tracked honestly rather than left for the next reader to discover.

- **No backups.** `restic-client.nix` was removed; `restic-password` remains in `secrets.yaml` unused. ZFS snapshots live on the same pool as the data and are not a substitute. Vaultwarden's DB, the PostgreSQL instances on `r820`, and `/var/lib/*` service state are currently unprotected.
- **No TLS or reverse proxy.** Every web UI above is plain HTTP on a LAN address. `homepage-dashboard` links to `https://*.derezzed.info` names that nothing yet serves, and Vaultwarden's `DOMAIN` does not match its real origin, which breaks passkeys.
- **Sanoid only covers `mediapool`.** `r730pool` has scrubs but no snapshots, even though `fleet.r730.zpool` is defined.
- **`nas-mount.nix`** reads CIFS credentials from an unmanaged plaintext `/etc/nixos/smb-secrets` and points at a `192.168.2.x` address that is not on this LAN.
- **Fan control** (`dell-poweredge.nix`) falls back to a low fan speed if sensor parsing fails, and has no `ExecStopPost` to hand control back to the iDRAC if the unit dies.
- **Partial `follows`.** `nixos-hardware`, `nix-cachyos-kernel`, `nix-flatpak`, and `millennium` don't follow the root `nixpkgs`, so the lock file carries several extra nixpkgs copies.
- **NUR and the Millennium overlay** are applied to every host, including `r730xd`, rather than only to desktops.
- **`users.users.aljam.extraGroups`** requests `plugdev` and `ubridge`, which nothing creates, and `docker`, which doesn't exist on Podman-only servers.

---

## License

[GNU General Public License v2](LICENSE.md).
