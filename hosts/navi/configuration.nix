{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/navi-desktop.nix
    ../../modules/features/remote-builder.nix
  ];

  networking.hostName = "navi";
  programs.corectrl.enable = true; # AMD Overclocking/Undervolting

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.configurationLimit = 10;

  system.stateVersion = lib.mkDefault "26.05";
}
