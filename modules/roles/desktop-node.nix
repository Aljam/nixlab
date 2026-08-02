{ config, pkgs, ... }:

{
  # --- Shared GUI Bootloader (GRUB) ---
  boot.loader.timeout = 5;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.configurationLimit = 10;
  boot.loader.grub.timeoutStyle = "menu";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  ### GUI (KDE Plasma)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- Desktop Programs & Device Integration ---
  programs.kdeconnect.enable = true;

  # --- Gaming Architecture ---
  programs.gamemode.enable = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Enable Pipewire for modern audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.nix-ld.enable = true;

  # Standard Desktop Apps
  environment.systemPackages = with pkgs; [
    librewolf
    git
    kitty
  ];
}
