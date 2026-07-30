{ config, pkgs, lib, ... }:

{
  # Accept Nvidia License globally
  nixpkgs.config.nvidia.acceptLicense = true;

  # Enable proprietary drivers and disable the X11 desktop environment
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = false;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Tesla P40 (Pascal architecture) requires the legacy 535 driver
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    open = false; # Proprietary blob required
    nvidiaSettings = false; 
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    
    # Defaults to false for headless (R730xd), but allows R730 to override to true
    modesetting.enable = lib.mkDefault false;
  };

  # Blacklist open-source driver
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Safe kernel parameters for headless enterprise Pascal cards
  boot.kernelParams = [
    "pcie_aspm=off"
    "nvidia-drm.modeset=0"
    "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1" # CRITICAL: Forces P40 Pascal support
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    
    # --- TTY & FRAMEBUFFER QUIRKS ---
    "console=tty0"            # Directs kernel messages to the primary system console
    "console=ttyS0,115200n8"  # Ensures iDRAC serial redirection works
    "fbcon=map:0"             # Forces the framebuffer console to stay mapped to slot 0 (ASPEED)
  ];

  # Ensure the local text login prompt is explicitly enabled on tty1
  systemd.services."getty@tty1".enable = true;

  # Common host-level utilities
  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    config.hardware.nvidia.package
  ];
}
