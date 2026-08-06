{ config, pkgs, lib, subnets, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/roles/storage-node.nix
    # ../../modules/roles/ai-node.nix
    ../../modules/features/nvidia-headless.nix
  ];

  networking.hostName = "r730";
  networking.hostId = "acccc16e"; # Required for ZFS

  boot.kernelPackages = pkgs.linuxPackages_6_1;  

  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true; # Passes the P40s into Docker

  hardware.nvidia = {
    modesetting.enable = true; # Overrides the headless module default
    nvidiaPersistenced = true; # Prevents power-state latency drops during AI training
  };

  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    cudatoolkit
    linuxPackages.nvidia_x11
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.configurationLimit = 10;

  system.stateVersion = lib.mkDefault "26.05";
}
