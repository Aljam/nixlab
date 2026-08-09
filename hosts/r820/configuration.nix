{ config, pkgs, subnets, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix 
    ../../modules/features/libvirt.nix
    ../../modules/roles/mail-node.nix
  ];

  networking.hostName = "r820";

  networking.bridges = {
    "br0" = {
      interfaces = [ "eno1" ];
    };
  };

  # Disable DHCP on the physical interface so it doesn't fight the bridge
  networking.interfaces.eno1.useDHCP = false;
  
  networking.interfaces.br0.ipv4.addresses = [{
    address = "${subnets.lan}.3";
    prefixLength = 24;
  }];

  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true; # Safe since it sits behind pfSense/HAProxy
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];

  # Override ZFS scrub from server-core since this host uses Hardware RAID
  services.zfs.autoScrub.enable = false;

  # Remote builder configuration
  nix.settings.trusted-users = [ "root" "aljam" ];
  nix.settings.allowed-users = [ "@users" ];

  system.stateVersion = lib.mkDefault "26.05";
}
