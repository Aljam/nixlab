{ config, pkgs, lib, ... }:

let
  mkArr = extra: {
    enable = true;
    group = "media";
  } // extra;

  mediaUsers = [ "sonarr" "radarr" "prowlarr" "bazarr" "readarr" "lidarr" "shoko" ];
in
{
  # SOPS secret declarations
  sops.secrets."autobrr_api_key" = {
    owner = "autobrr";
    group = "media";
  };
  sops.secrets."sonarr_api_key" = { 
    owner = "sonarr";
    group = "media";
  };
  sops.secrets."radarr_api_key" = { 
    owner = "radarr";
    group = "media";
  };

  # Declarative directory creation and permissions
  systemd.tmpfiles.rules = [
    "d /mnt/media/movies           0770 root media -"
    "d /mnt/media/tv               0770 root media -"
    "d /mnt/media/downloads        0770 root media -"
    "d /mnt/media/downloads/tv     0770 root media -"
    "d /mnt/media/downloads/movies 0770 root media -"
    "d /mnt/media/downloads/music  0770 root media -"
    "d /mnt/media/books            0770 root media -"
    "d /mnt/media/music            0770 root media -"
  ];

  # Service definitions tied to the shared media group
  services.sonarr   = mkArr { user = "sonarr"; };
  services.radarr   = mkArr { user = "radarr"; };
  services.bazarr   = mkArr { user = "bazarr"; };
  services.lidarr   = mkArr { user = "lidarr"; dataDir = "/var/lib/lidarr"; };
  services.readarr  = mkArr { user = "readarr"; };
  services.prowlarr = { enable = true; };

  # Ensure all service daemons bind to localhost
  systemd.services = {
    sonarr.environment.SONARR__SERVER__BINDADDRESS = "127.0.0.1";
    radarr.environment.RADARR__SERVER__BINDADDRESS = "127.0.0.1";
    prowlarr.environment.PROWLARR__SERVER__BINDADDRESS = "127.0.0.1";
    bazarr.environment.BAZARR__SERVER__BINDADDRESS = "127.0.0.1";
    readarr.environment.READARR__SERVER__BINDADDRESS = "127.0.0.1";
    lidarr.environment.LIDARR__SERVER__BINDADDRESS = "127.0.0.1";

    bazarr.serviceConfig.UMask = "0002";

    shoko.environment = {
      ASPNETCORE_URLS = "http://127.0.0.1:8111";
      SHOKO_PORT = "8111";
    };
  };

  # Enforce system user identities assigned to the media group
  users.users = lib.genAttrs mediaUsers (name: {
    isSystemUser = true;
    group = "media";
  });

  services.seerr = {
    enable = true;
    port = 5055;
  };

  # Recyclarr TRaSH Guides synchronization
  services.recyclarr = {
    enable = true;
    configuration = {
      sonarr.anime = {
        base_url = "http://localhost:8989";
        api_key._secret = config.sops.secrets.sonarr_api_key.path;
        quality_profiles = [
          { trash_id = "72dae194fc92bf828f32cde7744e51a1"; }
        ];
        custom_formats = [
          {
            trash_ids = [ 
              "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper (Sonarr)
              "418f50b10f1907201b6cfdf881f467b7" # Anime Dual Audio
              "026d5aadd1a6b4e550b134cb6c72b3ca" # uNCENSORED
            ];
            assign_scores_to = [
              { name = "WEB-1080p"; score = 500; }
            ];
          }
        ];
      };
      radarr.movies = {
        base_url = "http://localhost:7878";
        api_key._secret = config.sops.secrets.radarr_api_key.path;
        quality_profiles = [
          { trash_id = "d1d67249d3890e49bc12e275d989a7e9"; }
        ];
        custom_formats = [
          {
            trash_ids = [ "e7718d7a3ce595f289bfee26adc178f5" ];
            assign_scores_to = [
              { name = "HD Bluray + WEB"; score = 500; }
            ];
          }
        ];
      };
    };
  };

  services.audiobookshelf = {
    enable = true;
    port = 13378;
    host = "127.0.0.1";
  };

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets.autobrr_api_key.path;
    settings = { host = "127.0.0.1"; port = 7474; };
  };

  services.shoko = {
    enable = true;
  };
}
