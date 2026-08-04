{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/features/nvidia-headless.nix
    ../../modules/roles/media-node.nix
    ../../modules/roles/storage-node.nix
    ../../modules/features/observability.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;  
  boot.zfs.forceImportRoot = false;
  boot.kernelParams = [ "zfs.zfs_arc_max=68719476736" ];

  networking.hostName = "r730xd";
  networking.hostId = "d2083fdc"; # Required for ZFS

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.1.2";
      prefixLength = 24;
    }
  ];

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "1.1.1.1" ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.configurationLimit = 10;

  system.stateVersion = lib.mkDefault "26.05";
}
