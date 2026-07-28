{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "navi";

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
      gfxmodeEfi = "3440x1440";
      gfxmodeBios = "3440x1440";
      gfxpayloadEfi = "keep";
      configurationLimit = 10;
      timeoutStyle = "menu";
    };
  };

  ### External USB Enclosure Quirks
  boot.extraModprobeConfig = "options usb-storage use_uas=0";
  boot.kernelParams = [ 
    "usb-storage.quirks=152d:0551:u"
    "usbcore.autosuspend=-1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ### GUI (KDE Plasma)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  ### Virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  ### NAS CIFS Mount
  fileSystems."/run/media/aljam/share" = {
    device = "//192.168.2.12/share";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  ### Desktop Programs & Gaming
  programs = {
    kdeconnect.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };
  };

  users.users.aljam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
  };

  system.stateVersion = "23.11";
}
