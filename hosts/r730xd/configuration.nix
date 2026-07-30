{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/common.nix
    #../../modules/dell-fans.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;
  services.xserver.enable = false;

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # This is MANDATORY. Without it, NixOS ignores the Nvidia driver completely.
  services.xserver.videoDrivers = [ "nvidia" ];

  # CRITICAL FIX: Tell NixOS NOT to start a graphical desktop environment. 
  # This stops the infinite flashing cursor loop.
  services.xserver.enable = false;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    modesetting.enable = false;
    open = false; # Tesla P40 requires the proprietary blob
    nvidiaSettings = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Safe kernel parameters for headless enterprise Pascal cards on modern kernels
  boot.kernelParams = [
    "pcie_aspm=off"
    "nvidia-drm.modeset=0"
    "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1" # CRITICAL: Forces P40 Pascal support
    # --- TTY & FRAMEBUFFER QUIRKS ---
    "console=tty0"            # Directs kernel messages to the primary system console
    "console=ttyS0,115200n8"  # Ensures iDRAC serial redirection works if you use serial logging
    "fbcon=map:0"             # Forces the framebuffer console to stay mapped to slot 0 (ASPEED)
  ];
  
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Ensure the local text login prompt is explicitly enabled on tty1
  systemd.services."getty@tty1".enable = true;

  # --- Networking & System Identity ---
  networking.hostName = "r730xd";
  networking.hostId = "d2083fdc"; # ZFS strictly requires a unique 8-character hex string for every machine

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.1.2";
      prefixLength = 24;
    }
  ];

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "1.1.1.1" ];

  # --- Boot & Loaders ---
  boot.zfs.forceImportRoot = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ]; 
  boot.loader.grub.efiInstallAsRemovable = true;

  # --- Storage, Hardware & GPU Setup ---
  environment.systemPackages = with pkgs; [
    smartmontools
    nvtopPackages.full
    config.hardware.nvidia.package
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # --- Users, Groups & Directories ---
  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  # --- Media & Automation Services ---

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  users.groups.media = {};

  # Pass device nodes directly into the native service
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "media" "video" "render" ];
    DeviceAllow = [
      "/dev/nvidia0 rwm"
      "/dev/nvidiactl rwm"
      "/dev/nvidia-uvm rwm"
      "/dev/nvidia-uvm-tools rwm"
      "char-drm rwm"
    ];
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
    };
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.autobrr = {
    enable = true;
    secretFile = "/etc/nixos/secrets/autobrr.env";
    settings = {
      port = 7474;
      host = "0.0.0.0";
    };
  };

  services.recyclarr = {
    enable = true;
  };
  
  virtualisation.oci-containers.containers.qbitmanage = {
    image = "ghcr.io/starbix/qbitmanage:latest";
    environment = {
      QBT_RUN = "true";
      QBT_SCHEDULE = "1440";
    };
    volumes = [
      "/var/lib/qbitmanage:/config"
      "/mnt/pool/media:/data/media"
      "/var/lib/qbittorrent:/qbittorrent"
    ];
  };

  # --- Dashboard & Service Permissions ---
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "home.derezzed.info,192.168.1.2:8082";
    services = [
      {
        "Media & Requests" = [
          {
            Jellyfin = {
              href = "https://jellyfin.derezzed.info";
              description = "Media Streaming";
              icon = "jellyfin.png";
            };
          }
          {
            Seerr = {
              href = "https://seerr.derezzed.info";
              description = "Media Requests";
              icon = "seerr.png";
            };
          }
        ];
      }
      {
        "Automation & Downloads" = [
          {
            Sonarr = {
              href = "https://sonarr.derezzed.info";
              description = "TV Shows";
              icon = "sonarr.png";
            };
          }
          {
            Radarr = {
              href = "https://radarr.derezzed.info";
              description = "Movies";
              icon = "radarr.png";
            };
          }
          {
            Prowlarr = {
              href = "https://prowlarr.derezzed.info";
              description = "Indexers";
              icon = "prowlarr.png";
            };
          }
          {
            qBittorrent = {
              href = "http://192.168.1.2:8080";
              description = "Torrents";
              icon = "qbittorrent.png";
            };
          }
        ];
      }
    ];
  };

  system.stateVersion = "23.11";
}
