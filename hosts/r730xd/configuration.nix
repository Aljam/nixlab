{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/aljam.nix
    ../../modules/common.nix
    ../../modules/server-core.nix     # <-- Injects smartd, tmux, htop, ssh keys
    ../../modules/nvidia-headless.nix # <-- Injects Tesla P40 GPU drivers
    ../../modules/media-server.nix    # <-- Injects Jellyfin, Arr stack, UI
    ../../modules/graphics.nix
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
