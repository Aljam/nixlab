{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop-node.nix
    ../../modules/hardware/system76-laptop.nix
    ../../modules/features/remote-builder.nix
  ];

  networking.hostName = "oryx";
  
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  # Use "nodev" since grub will install to the EFI system partition without needing to target a specific raw disk block
  boot.loader.grub.device = "nodev";

  system.stateVersion = lib.mkDefault "26.05";
}
