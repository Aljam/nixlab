{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/system76-laptop.nix
  ];

  networking.hostName = "oryx";

  networking.networkmanager.enable = true;

  system.stateVersion = lib.mkDefault "26.05";
}
