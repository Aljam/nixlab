{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
  ];

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

  boot.zfs.forceImportRoot = false;

  # Tell GRUB to use EFI, not legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  
  # "nodev" tells GRUB we are using EFI and it doesn't need a raw legacy disk path
  boot.loader.grub.devices = [ "nodev" ]; 
  
  # Highly recommended for Dell PowerEdge servers to prevent the BIOS from "forgetting" the boot entry
  boot.loader.grub.efiInstallAsRemovable = true;

  # --- Storage & GPU Monitoring ---
  environment.systemPackages = with pkgs; [
    smartmontools
    nvtopPackages.full
  ];

  # Enable the SMART monitoring daemon for the ZFS drives
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  users.groups.media = {};

  # Automatic Directory Creation
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
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

  # Autobrr (Native NixOS Service)
  services.autobrr = {
    enable = true;
    port = 7474;
    # Requires a secret string file for session cookies
    # Create this manually: echo "your-random-string" > /var/lib/autobrr/secret
    secretKeyFile = "/var/lib/autobrr/secret"; 
  };
  
  # Recyclarr (Native NixOS Service - sets up systemd timers automatically)
  services.recyclarr = {
    enable = true;
  };
  
  # qBitManage (via Container, as there is no official native NixOS module)
  virtualisation.oci-containers.containers.qbitmanage = {
    image = "ghcr.io/starbix/qbitmanage:latest";
    environment = {
      QBT_RUN = "true";
      QBT_SCHEDULE = "1440"; # Runs automatically every 24 hours
    };
    volumes = [
      "/var/lib/qbitmanage:/config"
      "/mnt/pool/media:/data/media" # Your ZFS pool root
      "/var/lib/qbittorrent:/qbittorrent" # Path to your qBittorrent app data
    ];
  };

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

  # Enable Hardware Graphics Acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Load the Proprietary Nvidia Drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Ensure the driver is enabled
    modesetting.enable = true;
    
    # Optional but recommended for headless servers
    open = false; 
    nvidiaSettings = true;

    # THIS IS THE CRITICAL LINE
    # This forces NixOS to use the legacy 535.xx driver branch (or whichever legacy branch you need)
    # instead of the broken latest/beta drivers.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
  };

  # Grant Jellyfin GPU Permissions
  # This adds Jellyfin to the groups required to access /dev/dri/ where the GPU resides.
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "render" "video" ];
  };

  hardware.dell-fan-control.enable = true;

  # ZFS Maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  system.stateVersion = "23.11";
}
