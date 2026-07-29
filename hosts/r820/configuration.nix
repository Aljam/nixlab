# /hosts/r820/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix # Pulls in your SSH keys, Tailscale, timezones, and base packages
  ];

  # System Identity
  networking.hostName = "r820";

  # Tell GRUB to use EFI, not legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  
  # "nodev" tells GRUB we are using EFI and it doesn't need a raw legacy disk path
  boot.loader.grub.devices = [ "nodev" ]; 
  
  # Highly recommended for Dell PowerEdge servers to prevent the BIOS from "forgetting" the boot entry
  boot.loader.grub.efiInstallAsRemovable = true;
  
  # ZFS Host ID (Required if you deploy ZFS on this machine)
  # Generate a unique 8-character hex string using `head -c 4 /dev/urandom | od -A none -t x4`
  # networking.hostId = "replace_me"; 

  # --- 1. Massive Virtualization & Containers ---
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true; # Required for modern OS testing (like Windows 11 VMs)
      };
    };
    
    # Lightweight containers alongside heavy VMs
    lxd.enable = true;
    docker.enable = true; 
  };

  # --- 2. CI/CD & Nix Remote Build Offloading ---
  # This tells Nix to utilize the massive thread count across all 4 CPUs
  nix.settings = {
    max-jobs = "auto";
    cores = 0; # 0 tells Nix to use all available cores natively
    trusted-users = [ "root" "@wheel" "aljam" ]; # Allows your laptop to securely send build jobs here
  };

  # --- 3. Lab Simulation (GNS3) & System Utilities ---
  environment.systemPackages = with pkgs; [
    # Network Emulation
    gns3-server
    ubridge
    qemu_kvm
    
    # Core Networking & Virtualization Tools
    bridge-utils
    vlan
    virt-manager
    
    # Monitoring for all those threads
    htop
    btop
    tmux
  ];

  # --- 4. Virtualization Network Bridge (Isolated Lab) ---
  # Creates a dedicated internal bridge with no physical interfaces attached
  networking.bridges = {
    "br-isolated" = {
      interfaces = []; # Empty array guarantees no physical network leakage
    };
  };

  # Assign the R820 a static IP on this isolated bridge to act as the internal gateway
  networking.interfaces."br-isolated".ipv4.addresses = [ {
    address = "10.0.0.1";
    prefixLength = 24;
  } ];

  # Keep your physical NIC completely standard so the host R820 retains internet/SSH access
  networking.interfaces."eno1".useDHCP = true;
  # Do not change this value
  system.stateVersion = "23.11"; 
}
