{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/dell-fans.nix
  ];

  networking.hostName = "r730";
  networking.hostId = "acccc16e"; # ZFS strictly requires a unique 8-character hex string for every machine

  # Tell GRUB to use EFI, not legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  
  # "nodev" tells GRUB we are using EFI and it doesn't need a raw legacy disk path
  boot.loader.grub.devices = [ "nodev" ]; 
  
  # Highly recommended for Dell PowerEdge servers to prevent the BIOS from "forgetting" the boot entry
  boot.loader.grub.efiInstallAsRemovable = true;


  # Server Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------
  # DUAL TESLA P40 AI COMPUTE CONFIGURATION
  # ---------------------------------------------------------

  # Enable proprietary drivers for headless compute nodes
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Tesla P40 (Pascal architecture) uses the standard stable/production driver package
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
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

  # ZFS Maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  system.stateVersion = "23.11";
}
