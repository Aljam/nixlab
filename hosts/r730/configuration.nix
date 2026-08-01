{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/features/nvidia-headless.nix
  ];

  networking.hostName = "r730";
  networking.hostId = "acccc16e"; # ZFS requirement

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------
  # HOST-SPECIFIC AI COMPUTE OVERRIDES
  # ---------------------------------------------------------
  
  hardware.nvidia = {
    modesetting.enable = true; # Overrides the module default
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
}
