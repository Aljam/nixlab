# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

{
  services.readarr = {
    enable = true;
  };
}
