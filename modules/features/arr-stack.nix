{ config, pkgs, lib, ... }:

let
  # Shared defaults for *arr-style services
  bindAll = serviceName: envPrefix: {
    systemd.services.${serviceName}.environment."${envPrefix}__SERVER__BINDADDRESS" = "*";
  };

  # Force a system user into the media group (for modules that create their own user)
  forceMediaGroup = name: {
    users.users.${name} = {
      isSystemUser = true;
      group = lib.mkForce "media";
    };
  };

  # Common *arr options
  mkArr = extra: {
    enable = true;
    group = "media";
    openFirewall = true;
  } // extra;
in
{
  sops.secrets.autobrr_api_key = { };

  # Media directories (owned by media group)
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies    0770 root media -"
    "d /mnt/media/tv        0770 root media -"
    "d /mnt/media/downloads 0770 root media -"
    "d /mnt/media/books     0770 root media -"
    "d /mnt/media/music     0770 root media -"
  ];

  # ── Core *arr stack ──────────────────────────────────────────────
  services.sonarr = mkArr { user = "sonarr"; };
  services.radarr = mkArr { user = "radarr"; };
  services.bazarr = mkArr { user = "bazarr"; };
  services.lidarr = mkArr {
    dataDir = "/var/lib/lidarr";
  };
  services.readarr = mkArr { };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Bind addresses + group overrides
  systemd.services = {
    sonarr.environment.SONARR__SERVER__BINDADDRESS   = "*";
    radarr.environment.RADARR__SERVER__BINDADDRESS   = "*";
    prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "*";
    bazarr.environment.BAZARR__SERVER__BINDADDRESS   = "*";
    readarr.environment.READARR__SERVER__BINDADDRESS = "*";
    lidarr.environment.LIDARR__SERVER__BINDADDRESS   = "*";

    # Bazarr needs a looser umask so the media group can write
    bazarr.serviceConfig.UMask = "0002";
  };

  users.users = {
    prowlarr = { isSystemUser = true; group = lib.mkForce "media"; };
    bazarr   = { isSystemUser = true; group = lib.mkForce "media"; };
    readarr  = { isSystemUser = true; group = lib.mkForce "media"; };
    lidarr   = { isSystemUser = true; group = lib.mkForce "media"; };
    shoko    = { isSystemUser = true; group = "media"; };
  };

  # ── Other media helpers ──────────────────────────────────────────
  services.seerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };
  systemd.services.seerr.environment.HOST = "0.0.0.0";

  services.recyclarr.enable = true;

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "0.0.0.0";
    # openFirewall is not available on this module → open manually below
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

  # Only ports that are *not* covered by openFirewall
  networking.firewall = {
    allowedTCPPorts = [
      13378  # Audiobookshelf (no openFirewall option)
      8111   # Shoko (module does not open it)
    ];
    allowedUDPPorts = [
      9000   # Shoko AniDB
    ];
  };
}
