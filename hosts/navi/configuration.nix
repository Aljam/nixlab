{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/navi-desktop.nix
  ];

  networking.hostName = "navi";
  programs.corectrl.enable = true; # AMD Overclocking/Undervolting

  networking.networkmanager.enable = true;

  system.stateVersion = lib.mkDefault "26.05";
}
