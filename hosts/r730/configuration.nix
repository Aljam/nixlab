{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/aljam.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
    ../../modules/nvidia-headless.nix
    ../../modules/graphics.nix
  ];

  networking.hostName = "r730";
  networking.hostId = "acccc16e"; # ZFS requirement

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;

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
