{ config, pkgs, lib, ... }:

let
  mkArr = extra: {
    enable = true;
    group = "media";
  } // extra;

  mediaUsers = [ "prowlarr" "bazarr" "readarr" "lidarr" "shoko" ];
in
{
  sops.secrets.autobrr_api_key = { };

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

  # Bind to localhost + Bazarr umask + Shoko
  systemd.services = {
    sonarr.environment.SONARR__SERVER__BINDADDRESS     = "127.0.0.1";
    radarr.environment.RADARR__SERVER__BINDADDRESS     = "127.0.0.1";
    prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "127.0.0.1";
    bazarr.environment.BAZARR__SERVER__BINDADDRESS     = "127.0.0.1";
    readarr.environment.READARR__SERVER__BINDADDRESS   = "127.0.0.1";
    lidarr.environment.LIDARR__SERVER__BINDADDRESS     = "127.0.0.1";

    bazarr.serviceConfig.UMask = "0002";

    # Shoko has no bindAddress option — use ASP.NET Core env
    shoko.environment = {
      ASPNETCORE_URLS = "http://127.0.0.1:8111";
      SHOKO_PORT = "8111";
    };
  };

  users.users = lib.genAttrs mediaUsers (name: {
    isSystemUser = true;
    group = lib.mkForce "media";
  });

  # ── Other media helpers ──────────────────────────────────────────
  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  services.recyclarr.enable = true;

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "127.0.0.1";
  };

  services.autobrr = {
    enable = true;
    openFirewall = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    address = "127.0.0.1";
  };

  services.shoko.enable = true;

  # AniDB only (web UIs are localhost-only now)
  networking.firewall.allowedUDPPorts = [ 9000 ];
}
