{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix  
    ../../modules/desktop.nix
  ];

  networking.hostName = "oryx";

  ### Bootloader (GRUB)
  boot.loader = {
    timeout = 10;
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      device = "nodev";
      gfxmodeEfi = "1920x1200";
      gfxmodeBios = "1920x1200";
      gfxpayloadEfi = "keep";
      configurationLimit = 10;
      timeoutStyle = "menu";
    };
  };

  ### Nvidia & System76 Hardware Specifics
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_EnableGpuFirmware=1"
      "system76_acpi.brightness_hwmon=1"
      "nvidia-drm.modeset=1"
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  hardware.system76 = {
    kernel-modules.enable = true;
    firmware-daemon.enable = true;
    power-daemon.enable = true;
  };
  services.fwupd.enable = true;

  services = {
    thermald.enable = false;
    system76-scheduler.enable = true;
    power-profiles-daemon.enable = false;
  };
  powerManagement.cpuFreqGovernor = "performance";

  users.users.aljam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "23.11";
}
