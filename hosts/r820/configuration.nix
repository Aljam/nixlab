{ config, pkgs, lib, fleet, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix 
    ../../modules/features/libvirt.nix
    ../../modules/features/postgres.nix
    #../../modules/roles/mail-node.nix
  ];
  
  # Set servicesHostIP from fleet for HAProxy backend access
  servicesHostIP = fleet.r820.ip;
  
  networking.interfaces.eno1.ipv4.addresses = [{
    address = fleet.r820.ip;
    prefixLength = 24;
  }];

  # Remote builder configuration
  nix.settings.trusted-users = [ "root" "aljam" ];
  nix.settings.allowed-users = [ "@users" ];
}
