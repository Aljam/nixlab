{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;
  services.xserver.enable = false;

  hardware.enableRedistributableFirmware = true;

  boot.kernelParams = [ 
    "pcie_aspm=off"  # <--- CRITICAL: Stops the motherboard from dropping slot voltage
    "intel_iommu=on"
    "iommu=pt"
    "ipmi_si"
    "ipmi_devintf"
    "ipmi_msghandler"
  ];
  
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1b38
  '';
  
  boot.blacklistedKernelModules = [ "nouveau" "ast" "nvidia_drm" "nvidia_modeset" "nvidia_uvm" ];

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
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # --- Users, Groups & Directories ---
  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  # --- Media & Automation Services ---

  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers.jellyfin = {
      image = "jellyfin/jellyfin:latest";
      autoStart = true;
      ports = [ "8096:8096" ];
      
      # Map your ZFS media pool and config directories
      volumes = [
        "/mnt/media:/media"
        "/var/lib/jellyfin/config:/config"
        "/var/lib/jellyfin/cache:/cache"
      ];
      
      # 3. The VFIO Passthrough Configuration
      environment = {
        # Tell the Nvidia toolkit inside the container to grab the raw card
        NVIDIA_VISIBLE_DEVICES = "all";
        NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
      };
      
      # Force Docker to use the Nvidia runtime bridge
      extraOptions = [
        "--runtime=nvidia"
      ];
    };
  };

  # 4. Ensure the host firewall allows the Jellyfin port
  networking.firewall.allowedTCPPorts = [ 8096 ];

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
