{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/roles/storage-node.nix
    ../../modules/features/nvidia-headless.nix
    ../../modules/roles/ai-node.nix
  ];

  networking.hostName = "r730";
  networking.hostId = "acccc16e"; # Required for ZFS

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    pciutils
    lm_sensors
    tmux
    htop
  ];

  hardware.dell-fan-control.enable = true;

  system.stateVersion = lib.mkDefault "26.05";
}
