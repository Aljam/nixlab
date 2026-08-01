{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix 
  ];

  networking.hostName = "r820";
  
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];

  # Override the ZFS scrub from server-core since this uses Hardware RAID
  services.zfs.autoScrub.enable = false; 

  # Put your specific R820 workloads here (e.g., KVM, Proxmox, Gitlab Runners)
}
