![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat-square&logo=NixOS&logoColor=white)
![Flakes Enabled](https://img.shields.io/badge/Flakes-Enabled-blueviolet.svg?style=flat-square)
![GitOps](https://img.shields.io/badge/GitOps-Ready-brightgreen.svg?style=flat-square)
![Home Manager](https://img.shields.io/badge/Home%20Manager-Managed-orange.svg?style=flat-square)
![Sops-Nix](https://img.shields.io/badge/Encrypted-sops--nix-critical.svg?style=flat-square)

Welcome to **Nixlab**, a fully declarative, reproducible, and GitOps-driven multi-machine homelab infrastructure governed by a unified Nix flake. 

This repository manages everything from daily-driver workstations and mobile laptops to an enterprise PowerEdge server rack. By utilizing **NixOS**, **Home Manager**, **Disko**, and **sops-nix**, the entire fleet's OS packages, kernel configurations, ZFS storage arrays, user dotfiles, and encrypted secrets are defined entirely as code.

---

## 🏛️ Executive Overview & Core Architecture Tenets

Nixlab manages a diverse heterogeneous computing fleet ranging from daily-driver workstations and mobile development laptops to enterprise-grade server hardware. By leveraging NixOS, Home Manager, Disko, and sops-nix, the entire operating system state—including kernel configurations, ZFS storage topologies, localized user dotfiles, and encrypted application secrets—is completely defined as code and version controlled.

> **Core Architecture Tenets:**
> - **Reproducibility:** Pinned flake inputs ensure byte-for-byte identical system builds across all nodes.
> - **Modularity:** Decoupled roles, opt-in feature modules, and explicit hardware mapping eliminate duplication (DRY).
> - **Declarative Storage:** Automated disk partitioning, formatting, and ZFS pool creation via Disko.
> - **Secret Management:** Zero plaintext secrets; encrypted at rest via Age and managed dynamically with sops-nix.

---

## 🖥️ Fleet Architecture & Hardware Profiles

The lab consists of 5 distinct machines, strictly separated by hardware capabilities and operational roles using a DRY modular layout:

| Hostname | Type | Hardware Profile | Purpose & Core Workloads |
| :--- | :--- | :--- | :--- |
| **`navi`** | Desktop | Custom Desktop | Primary workstation. KDE Plasma, Hyprland Wayland compositor, Steam/Gaming, virtualization, and local development environment. |
| **`oryx`** | Laptop | System76 Laptop | Portable development node. Nvidia PRIME graphics offloading, battery management daemon tuning, and mobile networking profiles. |
| **`r730`** | Server | Dell PowerEdge R730 | AI compute & VM host. Dual Intel Xeon CPUs, dual Tesla P40 GPUs (Pascal architecture), and high-performance ZFS mirrored VDEVs. |
| **`r730xd`** | Server | Dell PowerEdge R730xd | Mass media & storage vault. 24-drive chassis with three 8-drive RAID-Z2 ZFS pools, Jellyfin (NVENC acceleration), Arr automation stack, and Vaultwarden. |
| **`r820`** | Server | Dell PowerEdge R820 | Heavy CI/CD compute & virtualization node. Quad-socket headless architecture, hardware RAID controller, and isolated network test beds. |

---

## 📂 Repository Codebase Structure

The codebase follows a strict modular design pattern. Logic is decoupled into reusable roles, opt-in feature modules, and hardware-specific configurations.

```text
nixlab/
├── flake.nix               # The central entry point defining inputs, outputs, and host configurations
├── flake.lock              # Pinned package commit snapshot ensuring absolute build reproducibility
├── hosts/                  # Host-specific configurations and hardware mapping
│   ├── navi/               # Desktop configuration & hardware-configuration.nix
│   ├── oryx/               # Laptop configuration & hardware-configuration.nix
│   ├── r730/               # AI compute configuration & Disko Mirrored VDEV layout
│   ├── r730xd/             # Media server configuration & Disko 24-drive RAID-Z2 layout
│   └── r820/               # Quad-socket compute node configuration (hardware RAID/ext4)
├── modules/                # Reusable system modules
│   ├── features/           # Opt-in software services & toolsets (arr-stack, jellyfin, vaultwarden, 
│   │                       #   torrents, monitoring, libvirt, hyprland, gaming, nvidia-headless)
│   ├── hardware/           # Hardware-specific quirks (dell-poweredge, system76-laptop, navi-desktop)
│   └── roles/              # Fleet-wide baselines (common.nix, server-core.nix, desktop-node.nix, media-node.nix)
├── users/aljam/            # Standalone Home Manager user profiles
│   ├── home.nix            # Core CLI environment (Fish shell, Git, Neovim, CLI utilities)
│   ├── home-gui.nix        # Graphical desktop additions (Kitty terminal, browsers, app suites)
│   └── nixos.nix           # User account definitions and system bindings
└── secrets/                # Encrypted infrastructure secrets
    └── secrets.yaml        # Master sops-nix encrypted credential store
    
```

---

## ⚙️ Deep-Dive Component Breakdown

### 1. Flake Architecture & Inputs (`flake.nix`)
The root flake orchestrates all configurations by consuming upstream stable and unstable channels, hardware modules, and specialized toolsets such as Disko and sops-nix. Each host is instantiated via `nixpkgs.lib.nixosSystem`, binding system definitions directly to corresponding hardware manifests.

### 2. Declarative Storage & Disko
Storage topologies on production servers (`r730` and `r730xd`) are provisioned entirely through declarative Disko scripts. This guarantees that disk partitioning, GUID partition tables, ZFS pool creation (`zpool`), dataset hierarchies, and mount options are reproducible across bare-metal reinstalls without manual partitioning.

### 3. Role & Feature Modularity
System behavior is divided into two structural layers:
- **Roles (`modules/roles/`):** Establish mandatory baselines for all systems (`common.nix`), lightweight headless servers (`server-core.nix`), desktop workstations (`desktop-node.nix`), and storage nodes (`media-node.nix`).
- **Features (`modules/features/`):** Opt-in service modules containing containerized or native systemd service definitions for applications like Jellyfin, Vaultwarden, the Arr media stack, and monitoring agents.

### 4. Home Manager & User Dotfiles
User `aljam` is managed via Home Manager, separating core CLI tool configurations (`home.nix` featuring Fish, Neovim, Git, and modern CLI utilities) from graphical desktop components (`home-gui.nix` featuring Kitty, window managers, and application suites). This configuration applies identically across desktop (`navi`) and laptop (`oryx`) hosts.

### 5. Secret Management with sops-nix
Infrastructure credentials, API tokens, and environment overrides (such as `autobrr.enc.env`) are encrypted at rest using Age keys via `sops-nix`. Secrets are decrypted directly into runtime systemd service environments or secure runtime paths during system activation, ensuring zero credential leakage in version control.

---

## 🚀 Getting Started & Deployment

### Prerequisites
- Install Nix with Flakes enabled (`experimental-features = nix-command flakes`).
- Ensure Git is installed on the control machine.

### Initial Flake Deployment
To deploy a specific host configuration (e.g., `navi`) from within the repository working directory, execute:
```bash
sudo nixos-rebuild switch --flake .#navi
```

### Remote Deployment via Deploy-rs (Optional)
For remote server management across the rack (`r730`, `r730xd`, `r820`), remote activation can be triggered directly from the workstation:
```bash
deploy .#r730xd
```

---

## 📜 License & Maintenance
Maintained under an open infrastructure philosophy. Contributions, issue reports, and pull requests to improve modularity or expand hardware support are welcome.
