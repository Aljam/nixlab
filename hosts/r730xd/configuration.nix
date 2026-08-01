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
  ];

  # --- Hardware & Boot Defaults ---
  boot.kernelPackages = pkgs.linuxPackages_6_1;
  hardware.enableRedistributableFirmware = true;
  
  boot.zfs.forceImportRoot = false;

  # --- System Identity & Networking ---
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
}
