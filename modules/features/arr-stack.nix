{ config, pkgs, lib, ... }:

let
  mkArr = extra: {
    enable = true;
    group = "media";
    openFirewall = true;
  } // extra;

  mediaUsers = [ "prowlarr" "bazarr" "readarr" "lidarr" "shoko" ];
in
{
  sops.secrets.autobrr_api_key = { };

  systemd.tmpfiles.rules = [
    "d /mnt/media/movies    0770 root media -"
    "d /mnt/media/tv        0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
    "d /mnt/media/downloads/tv  0770 root media -"
    "d /mnt/media/downloads/movies  0770 root media -"
    "d /mnt/media/downloads/music  0770 root media -"
    "d /mnt/media/books     0770 root media -"
    "d /mnt/media/music     0770 root media -"
  ];

  services.sonarr  = mkArr { user = "sonarr"; };
  services.radarr  = mkArr { user = "radarr"; };
  services.bazarr  = mkArr { user = "bazarr"; };
  services.lidarr  = mkArr { dataDir = "/var/lib/lidarr"; };
  services.readarr = mkArr { };
  services.prowlarr = { enable = true; openFirewall = true; };

  systemd.services = {
    sonarr.environment.SONARR__SERVER__BINDADDRESS     = "0.0.0.0";
    radarr.environment.RADARR__SERVER__BINDADDRESS     = "0.0.0.0";
    prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "0.0.0.0";
    bazarr.environment.BAZARR__SERVER__BINDADDRESS     = "0.0.0.0";
    readarr.environment.READARR__SERVER__BINDADDRESS   = "0.0.0.0";
    lidarr.environment.LIDARR__SERVER__BINDADDRESS     = "0.0.0.0";

    bazarr.serviceConfig.UMask = "0002";

    shoko.environment = {
      ASPNETCORE_URLS = "http://0.0.0.0:8111";
      SHOKO_PORT = "8111";
    };
  };

  users.users = lib.genAttrs mediaUsers (name: {
    isSystemUser = true;
    group = lib.mkForce "media";
  });

  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  services.recyclarr.enable = true;

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "0.0.0.0";
    openFirewall = true;
  };

  services.autobrr = {
    enable = true;
    openFirewall = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    settings = { host = "0.0.0.0"; port = 7474; };
  };

  services.shoko = {
    enable = true;
    openFirewall = true;
  };

  # AniDB only (web UIs are localhost-only now)
  networking.firewall.allowedUDPPorts = [ 9000 ];
}
