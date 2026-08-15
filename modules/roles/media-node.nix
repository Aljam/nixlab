{ config, pkgs, domains, fleet, ... }: {
  imports = [
    ../features/homepage.nix
    ../features/radarr.nix
    ../features/sonarr.nix
    ../features/lidarr.nix
    ../features/readarr.nix
    ../features/bazarr.nix
    ../features/seerr.nix
    ../features/audiobookshelf.nix
    ../features/autobrr.nix
    ../features/shoko.nix
    ../features/torrents.nix
    ../features/jellyfin.nix
    ../features/vaultwarden.nix
    ../features/grafana.nix
  ];
}
