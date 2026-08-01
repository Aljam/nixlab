{ config, pkgs, ... }:

{
  users.groups.media = {};

  # Define the SOPS secret
  sops.secrets."autobrr.env" = {
    sopsFile = ../../secrets/autobrr.enc.env;
    format = "dotenv";
    owner = "autobrr";
    group = "media";
  };

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
    secretFile = config.sops.secrets."autobrr.env".path;
    settings = { port = 7474; host = "0.0.0.0"; };
  };
  
  services.recyclarr.enable = true;
}
