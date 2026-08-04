{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/system76-laptop.nix
    ../../modules/features/remote-builder.nix
  ];

  networking.hostName = "oryx";

  system.stateVersion = lib.mkDefault "26.05";
}
