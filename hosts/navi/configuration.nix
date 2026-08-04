{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/features/graphics.nix
    ../../modules/hardware/navi-desktop.nix
    ../../modules/features/remote-builder.nix
  ];

  networking.hostName = "navi";
  programs.corectrl.enable = true; # AMD Overclocking/Undervolting

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  system.stateVersion = lib.mkDefault "26.05";
}
