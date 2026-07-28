{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
  ];

  networking.hostName = "r730";

  # Server Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------
  # DUAL TESLA P40 AI COMPUTE CONFIGURATION
  # ---------------------------------------------------------

  # Enable proprietary drivers for headless compute nodes
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Tesla P40 (Pascal architecture) uses the standard stable/production driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = false; # Pascal cards require the proprietary closed-source kernel module
    nvidiaPersistenced = true; # Prevents power-state latency drops during AI training/inference
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable global CUDA support for packages compiled in this environment
  nixpkgs.config.cudaSupport = true;

  # Host-level utilities and AI toolchain packages
  environment.systemPackages = with pkgs; [
    cudatoolkit
    linuxPackages.nvidia_x11
    pciutils
    lm_sensors
    tmux
    htop
    nvtopPackages.full
  ];

  hardware.dell-fan-control.enable = true;

  # System User
  users.users.aljam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "23.11";
}
