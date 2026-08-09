{ config, pkgs, lib, ... }:

let
  # Common *arr options
  mkArr = extra: {
    enable = true;
    group = "media";
    openFirewall = true;
  } // extra;

  # Force system users into the media group
  mediaUsers = [ "prowlarr" "bazarr" "readarr" "lidarr" "shoko" ];
in
{
  sops.secrets.autobrr_api_key = { };

  # Media directories
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies    0770 root media -"
    "d /mnt/media/tv        0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
    "d /mnt/media/books     0770 root media -"
    "d /mnt/media/music     0770 root media -"
  ];

  # ── Core *arr stack ──────────────────────────────────────────────
  services.sonarr  = mkArr { user = "sonarr"; };
  services.radarr  = mkArr { user = "radarr"; };
  services.bazarr  = mkArr { user = "bazarr"; };
  services.lidarr  = mkArr { dataDir = "/var/lib/lidarr"; };
  services.readarr = mkArr { };
  services.prowlarr = { enable = true; };

  # Bind to all interfaces + Bazarr umask
  systemd.services = {
    sonarr.environment.SONARR__SERVER__BINDADDRESS     = "127.0.0.1";
    radarr.environment.RADARR__SERVER__BINDADDRESS     = "127.0.0.1";
    prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "127.0.0.1";
    bazarr.environment.BAZARR__SERVER__BINDADDRESS     = "127.0.0.1";
    readarr.environment.READARR__SERVER__BINDADDRESS   = "127.0.0.1";
    lidarr.environment.LIDARR__SERVER__BINDADDRESS     = "127.0.0.1";

    bazarr.serviceConfig.UMask = "0002";
  };

  # Force media group for services that create their own user
  users.users = lib.genAttrs mediaUsers (name: {
    isSystemUser = true;
    group = lib.mkForce "media";
  });

  # ── Other media helpers ──────────────────────────────────────────
  services.seerr = {
    enable = true;
    port = 5055;
  };
  systemd.services.seerr.environment.HOST = "127.0.0.1";

  services.recyclarr.enable = true;

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "127.0.0.1";
  };

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    settings = {
      port = 7474;
      host = "127.0.0.1";
    };
  };

  services.shoko.enable = true;

  # Only ports not covered by openFirewall
  networking.firewall = {
    allowedTCPPorts = [
      13378  # Audiobookshelf
      8111   # Shoko
    ];
    allowedUDPPorts = [
      9000   # Shoko AniDB
    ];
  };
}
