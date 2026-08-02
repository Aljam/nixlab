{ config, pkgs, ... }:

{
  users.groups.media = {};

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # Hardware acceleration passthrough for Jellyfin
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
}
