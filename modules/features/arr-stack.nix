{ config, pkgs, ... }:

{
  users.groups.media = {};

  # Directory structures for media
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  services.sonarr = { enable = true; openFirewall = true; group = "media"; settings.server.bindAddress = "0.0.0.0"; };
  services.radarr = { enable = true; openFirewall = true; group = "media"; settings.server.bindAddress = "0.0.0.0"; };
  services.prowlarr = { enable = true; openFirewall = true; settings.server.bindAddress = "0.0.0.0"; };
  services.seerr = { enable = true; openFirewall = true; };
  
  services.autobrr = {
    enable = true;
    secretFile = "/etc/nixos/secrets/autobrr.env";
    settings = { port = 7474; host = "0.0.0.0"; };
  };
  
  services.recyclarr.enable = true;
}
