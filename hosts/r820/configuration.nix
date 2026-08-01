{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix 
    ../../modules/features/libvirt.nix
  ];

  # Bootloader setup for standard non-ZFS partition layout
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];

  networking.hostName = "r820";

  # Configure a network bridge (br0) for Libvirt VMs
  # Note: Replace 'eno1' with the actual physical network interface name
  networking.bridges = {
    "br0" = {
      interfaces = [ "eno1" ];
    };
  };

  # Disable DHCP on the physical interface so it doesn't fight the bridge for an IP
  networking.interfaces.eno1.useDHCP = false;

  # Assign the static IP address directly to the bridge
  networking.interfaces.br0.ipv4.addresses = [{
    address = "192.168.1.3"; # Ensure this matches your pfSense schema
    prefixLength = 24;
  }];

  # --- The Web GUI (Cockpit) ---
  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true; # Safe if behind pfSense/HAProxy
      };
    };
  };

  # Open the GUI port
  networking.firewall.allowedTCPPorts = [ 9090 ];

  # Override the ZFS scrub from server-core since this uses Hardware RAID
  services.zfs.autoScrub.enable = false;

  # Enable the Nix daemon to act as a remote builder
  nix.settings.trusted-users = [ "root" "aljam" ];
  
  # Allow the system to accept remote builds
  nix.settings.allowed-users = [ "@users" ];

  # Put your specific R820 workloads here (e.g., KVM, Proxmox, Gitlab Runners)
}
