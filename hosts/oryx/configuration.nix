{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix  
    ../../modules/desktop.nix # Pulls in generic GRUB, KDE, Steam, Audio
    ../../modules/aljam.nix   # Pulls in your identity
    ../../modules/graphics.nix
  ];

  networking.hostName = "oryx";

  # --- Oryx-Specific Bootloader Overrides (Laptop Display) ---
  boot.loader.grub.gfxmodeEfi = "1920x1200";
  boot.loader.grub.gfxmodeBios = "1920x1200";
  boot.loader.grub.gfxpayloadEfi = "keep";

  # --- Kernel & Hardware Parameters ---
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_EnableGpuFirmware=1"
    "system76_acpi.brightness_hwmon=1"
    "nvidia-drm.modeset=1"
  ];

  # --- Graphics & Nvidia PRIME Offloading ---
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.powerManagement.enable = true;

  # Explicit Bus IDs for Intel/Nvidia Graphics Switching
  hardware.nvidia.prime.sync.enable = true;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # --- System76 Quirks & Power Management ---
  hardware.system76.kernel-modules.enable = true;
  hardware.system76.firmware-daemon.enable = true;
  hardware.system76.power-daemon.enable = true;

  services.fwupd.enable = true;
  services.system76-scheduler.enable = true;

  # Disable conflicting generic Linux power daemons
  services.thermald.enable = false;
  services.power-profiles-daemon.enable = false;

  powerManagement.cpuFreqGovernor = "performance";
}
