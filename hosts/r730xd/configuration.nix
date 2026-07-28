{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
  ];

  networking.hostName = "r730xd";
  networking.hostId = "d4e5f6g7"; # ZFS strictly requires a unique 8-character hex string for every machine

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
  };

  # 4. The Arr Stack
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # 5. Jellyseerr (For requesting media)
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # 6. Download Client (qBittorrent)
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # Enable Hardware Graphics Acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Load the Proprietary Nvidia Drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Use the proprietary, closed-source drivers for the P40
    nvidiaSettings = false; # Disable the graphical settings menu since this is a headless server
  };

  # Grant Jellyfin GPU Permissions
  # This adds Jellyfin to the groups required to access /dev/dri/ where the GPU resides.
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "render" "video" ];
  };

  hardware.dell-fan-control.enable = true;
}
