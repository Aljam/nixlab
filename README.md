# ❄️ Nixlab

![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat-square&logo=NixOS&logoColor=white)
![Flakes Enabled](https://img.shields.io/badge/Flakes-Enabled-blueviolet.svg?style=flat-square)
![GitOps](https://img.shields.io/badge/GitOps-Ready-brightgreen.svg?style=flat-square)
![Home Manager](https://img.shields.io/badge/Home%20Manager-Managed-orange.svg?style=flat-square)

Welcome to **Nixlab**, a fully declarative, reproducible, and GitOps-driven multi-machine homelab infrastructure governed by a unified Nix flake. 

This repository manages everything from daily-driver workstations and mobile laptops to an enterprise PowerEdge server rack. By utilizing **NixOS**, **Home Manager**, **Disko**, and **sops-nix**, the entire fleet's OS packages, kernel configurations, ZFS storage arrays, user dotfiles, and encrypted secrets are defined entirely as code.

---

## 🖥️ Fleet Architecture & Hardware Profiles

The lab consists of 5 distinct machines, strictly separated by hardware capabilities and operational roles using a DRY modular layout:

| Hostname | Type | Hardware Profile | Purpose & Core Workloads |
| :--- | :--- | :--- | :--- |
| **`navi`** | Desktop | Custom Desktop | Primary workstation. KDE Plasma, Hyprland Wayland compositor, Steam/Gaming, virtualization, and local development. |
| **`oryx`** | Laptop | System76 Laptop | Portable development node. Nvidia PRIME graphics offloading, battery management, and power daemon tuning. |
| **`r730`** | Server | Dell PowerEdge R730 | AI compute & VM host. Dual Intel Xeon CPUs, dual Tesla P40 GPUs (Pascal architecture), and ZFS mirrored VDEVs. |
| **`r730xd`** | Server | Dell PowerEdge R730xd | Mass media & storage vault. 24-drive chassis with three 8-drive RAID-Z2 ZFS pools, Jellyfin (NVENC acceleration), Arr automation stack, and Vaultwarden. |
| **`r820`** | Server | Dell PowerEdge R820 | Heavy CI/CD compute & virtualization node. Quad-socket headless architecture, hardware RAID controller, and isolated network test beds. |

---

## 📂 Repository Structure

The codebase follows a strict modular design pattern. Logic is decoupled into reusable roles, opt-in feature modules, and hardware-specific configurations.

```text
nixlab/
├── flake.nix                 # The central entry point defining inputs, outputs, and host configurations
├── flake.lock                # Pinned package commit snapshot ensuring absolute build reproducibility
├── hosts/                    # Host-specific configurations and hardware mapping
│   ├── navi/                 # Desktop configuration & hardware-configuration.nix
│   ├── oryx/                 # Laptop configuration & hardware-configuration.nix
│   ├── r730/                 # AI compute configuration & Disko Mirrored VDEV layout
│   ├── r730xd/               # Media server configuration & Disko 24-drive RAID-Z2 layout
│   └── r820/                 # Quad-socket compute node configuration (hardware RAID/ext4)
├── modules/                  # Reusable system modules
│   ├── features/             # Opt-in software services & toolsets (arr-stack, jellyfin, vaultwarden, 
│   │                         #   torrents, monitoring, libvirt, hyprland, gaming, nvidia-headless)
│   ├── hardware/             # Hardware-specific quirks (dell-poweredge, system76-laptop, navi-desktop)
│   └── roles/                # Fleet-wide baselines (common.nix, server-core.nix, desktop-node.nix, media-node.nix)
├── users/aljam/              # Standalone Home Manager user profiles
│   ├── home.nix              # Core CLI environment (Fish shell, Git, Neovim, CLI utilities)
│   ├── home-gui.nix          # Graphical desktop additions (Kitty terminal, browsers, app suites)
│   └── nixos.nix             # User account definitions and system bindings
└── secrets/                  # Encrypted infrastructure secrets
    ├── secrets.yaml          # Master sops-nix encrypted credential store
    └── autobrr.enc.env       # Application-specific encrypted environment variables
