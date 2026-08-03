# ❄️ Nixlab 

![NixOS](https://img.shields.io/badge/NixOS-24.11-blue.svg?style=flat-square&logo=NixOS&logoColor=white)
![Flakes Enabled](https://img.shields.io/badge/Flakes-Enabled-blueviolet.svg?style=flat-square)
![GitOps](https://img.shields.io/badge/GitOps-Ready-brightgreen.svg?style=flat-square)

Welcome to **Nixlab**, my fully declarative, reproducible, and GitOps-driven multi-machine homelab. 

This repository manages everything from my personal workstations to my enterprise rack servers using a single, unified Nix flake. By leveraging [NixOS](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), [Disko](https://github.com/nix-community/disko), and [sops-nix](https://github.com/Mic92/sops-nix), the entire fleet's OS packages, services, storage pools, and dotfiles are defined as code.

---

## 🖥️ Fleet Overview

The lab consists of 5 distinct machines, each with specialized hardware configurations and roles:

| Hostname | Type | Hardware Profile | Purpose / Roles |
| :--- | :--- | :--- | :--- |
| **`navi`** | Desktop | Custom Desktop | Primary workstation. GUI apps, Steam/Gaming, KDE Plasma, Hyprland, and VMs. |
| **`oryx`** | Laptop | System76 Laptop | Portable development. Nvidia PRIME offloading, battery & power daemon tuning. |
| **`r730`** | Server | Dell PowerEdge R730 | AI compute & VM host. Dual Tesla P40 GPUs, ZFS mirrored VDEVs, CUDA workloads. |
| **`r730xd`** | Server | Dell PowerEdge R730xd | Mass storage & Media server. 24-drive RAID-Z2 ZFS pool, Jellyfin (NVENC), Arr stack, Vaultwarden. |
| **`r820`** | Server | Dell PowerEdge R820 | Heavy CI/CD compute node. Quad-socket headless builder, hardware RAID, virtualization lab. |

---

## 📂 Repository Architecture

The codebase follows a strictly modular, DRY (Don't Repeat Yourself) philosophy. Logic is cleanly decoupled into roles, features, and hardware profiles.

```text
nixlab/
├── flake.nix                 # The brain: unified inputs/outputs defining all hosts
├── flake.lock                # Pinned package commit snapshot for absolute reproducibility
├── hosts/                    # Host-specific identities and configurations
│   ├── navi/                 
│   ├── oryx/                 
│   ├── r730/                 # Includes Disko layout for Mirrored VDEVs
│   ├── r730xd/               # Includes Disko layout for massive RAID-Z2 array
│   └── r820/                 
├── modules/                  # Shared system modules
│   ├── features/             # Opt-in services (e.g., arr-stack, jellyfin, vaultwarden, nvidia-headless)
│   ├── hardware/             # Opt-in hardware quirks (e.g., dell-poweredge, system76-laptop)
│   └── roles/                # Fleet-wide baselines (common.nix, server-core.nix, desktop-node.nix)
├── users/aljam/              # Standalone Home Manager configs
│   ├── home.nix              # Core CLI environment (Fish, Git, Neovim)
│   └── home-gui.nix          # Desktop GUI environment (Kitty, Browsers, etc.)
└── secrets/                  # SOPS encrypted secrets (Wireguard, DB passwords, Autobrr envs)
