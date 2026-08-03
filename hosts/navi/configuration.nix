{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/features/graphics.nix
    ../../modules/hardware/navi-desktop.nix
  ];

  networking.hostName = "navi";
  programs.corectrl.enable = true; # AMD Overclocking/Undervolting

  system.stateVersion = lib.mkDefault "26.05";
}
