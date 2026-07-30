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
  networking.nameservers = [ "192.168.1.1" ];

  # Tell GRUB to use EFI, not legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  
  # "nodev" tells GRUB we are using EFI and it doesn't need a raw legacy disk path
  boot.loader.grub.devices = [ "nodev" ]; 
  
  # Highly recommended for Dell PowerEdge servers to prevent the BIOS from "forgetting" the boot entry
  boot.loader.grub.efiInstallAsRemovable = true;

  # --- NEW: Storage & GPU Monitoring ---
  environment.systemPackages = with pkgs; [
    smartmontools
    nvtopPackages.full
  ];

  # Enable the SMART monitoring daemon for the ZFS drives
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # 1. The Shared Media Group
  # This guarantees all media services can freely read/write to your ZFS pool without Linux permission conflicts.
  users.groups.media = {};

  # 2. Automatic Directory Creation
  # Declaratively creates your library folders on the ZFS pool with the correct group permissions.
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  # 3. Jellyfin Media Server
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
  };

  # 4. The Arr Stack
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      server = {
        bindAddress = "0.0.0.0";
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

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
  };

  # 5. Jellyseerr (For requesting media)
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
  };

  # 6. Download Client (qBittorrent)
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      server = {
        bindAddress = "0.0.0.0";
      };
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
