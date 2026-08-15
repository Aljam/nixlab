# DEPRECATED: arr-stack.nix
#
# This file is deprecated and will be removed in a future release.
# Please use modules/roles/media-node.nix instead, which imports all
# individual ARR service modules directly.
#
# Individual modules are now available:
# - radarr.nix
# - sonarr.nix
# - lidarr.nix
# - readarr.nix
# - bazarr.nix
# - seerr.nix (formerly jellyseerr)
# - audiobookshelf.nix
# - autobrr.nix
# - shoko.nix
#
# To use individual services, import them directly or use media-node.nix.

{ config, pkgs, domains, fleet, ... }: {
  imports = [
    ./radarr.nix
    ./sonarr.nix
    ./lidarr.nix
    ./readarr.nix
    ./bazarr.nix
    ./seerr.nix
    ./audiobookshelf.nix
    ./autobrr.nix
    ./shoko.nix
  ];
  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.lidarr.enable = true;
  services.readarr.enable = true;
  services.bazarr.enable = true;
  services.seerr.enable = true;
  services.audiobookshelf.enable = true;
  services.autobrr.enable = true;
  services.shoko.enable = true;
}
