{ config, pkgs, lib, ... }:

{
  sops.secrets.autobrr_api_key = {};

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies 0770 root media -"
    "d /mnt/media/tv 0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
  ];

  services.sonarr = {
    enable = true;
    user = "sonarr";
    group = "media";
    openFirewall = true;
  };
  systemd.services.sonarr.environment.SONARR__SERVER__BINDADDRESS = "*";

  services.radarr = {
    enable = true;
    user = "radarr";
    group = "media";
    openFirewall = true;
  };
  systemd.services.radarr.environment.RADARR__SERVER__BINDADDRESS = "*";

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.prowlarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "*";

  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };
  systemd.services.seerr.environment = {
    HOST = "0.0.0.0";
  };

services.bazarr = {
    enable = true;
    user = "bazarr";
    group = "media";
    openFirewall = true;
  };
  
  users.users.bazarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.bazarr.environment.BAZARR__SERVER__BINDADDRESS = "*";
  systemd.services.bazarr.serviceConfig.UMask = "0002";

  services.recyclarr.enable = true;

  services.readarr = {
    enable = true;
    openFirewall = true;
  };
  
  users.users.readarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.readarr.environment.READARR__SERVER__BINDADDRESS = "*";

  services.lidarr = {
    enable = true;
    dataDir = "/var/lib/lidarr";
    openFirewall = true;
  };
  
  users.users.lidarr = {
    isSystemUser = true;
    group = lib.mkForce "media";
  };
  systemd.services.lidarr.environment.LIDARR__SERVER__BINDADDRESS = "*";

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "0.0.0.0";
  };

  services.autobrr = {
    enable = true;
    openFirewall = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    settings = {
      port = 7474;
      host = "0.0.0.0";
    };
  };

  services.shoko.enable = true;
  
  users.users.shoko = { 
    isSystemUser = true;
    group = "media"; 
  };

  networking.firewall.allowedTCPPorts = [
    5055  # Seerr
    6767  # Bazarr
    7474  # Autobrr
    7878  # Radarr
    8111  # Shoko
    8686  # Lidarr
    8787  # Readarr
    8989  # Sonarr
    9696  # Prowlarr
    13378 # Audiobookshelf
  ];

  networking.firewall.allowedUDPPorts = [ 9000 ]; # shoko anidb
}
