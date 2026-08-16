{ config, pkgs, lib, fleet, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/features/nvidia-headless.nix
    ../../modules/roles/media-node.nix
    ../../modules/roles/storage-node.nix
    ../../modules/features/prometheus-server.nix
    ../../modules/features/grafana.nix 
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;  
  boot.zfs.forceImportRoot = false;
  boot.kernelParams = [ "zfs.zfs_arc_max=68719476736" ];

  networking.hostId = "d2083fdc"; # Required for ZFS

  # Set servicesHostIP from fleet for HAProxy backend access
  servicesHostIP = fleet.r730xd.ip;

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = fleet.r730xd.ip;
      prefixLength = 24;
    }
  ];
}
