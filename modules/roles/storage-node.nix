{ config, lib, pkgs, ... }:

{
  imports = [
    ../features/sanoid.nix
  ];

  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
