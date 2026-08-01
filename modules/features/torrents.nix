{ config, pkgs, ... }:

{
  users.groups.media = {};

  services.qbittorrent.enable = true;
  services.qbittorrent.openFirewall = true;
  services.qbittorrent.group = "media";

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
}
