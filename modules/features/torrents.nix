{ config, pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
    webuiPort = 8080;
  };

  virtualisation.oci-containers.containers.qbitmanage = {
    image = "ghcr.io/starbix/qbitmanage:latest";
    environment = {
      QBT_RUN = "true";
      QBT_SCHEDULE = "1440";
    };
    volumes = [
      "/var/lib/qbitmanage:/config"
      "/mnt/media:/data/media"
      "/var/lib/qbittorrent:/qbittorrent"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];  # qBittorrent
}
