{ config, pkgs, ... }:

{
  imports = [
    ../features/libvirt.nix
    ../features/gaming.nix
    ../features/graphics.nix
    ../features/audio.nix
    ../features/emulation.nix
    ../features/monitoring.nix
    ../features/hyprland.nix
  ];

  # --- Btrfs Maintenance ---
  #  services.btrfs.autoScrub = {
  #    enable = true;
  #    interval = "monthly";
  #    fileSystems = [ "/" "/mnt/your-game-drives" ]; # Add your specific mount points here
  #  };
  
  
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

  programs.nix-ld.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Allows you to type 'docker' in the terminal
  };

  # Standard Desktop Apps
  environment.systemPackages = with pkgs; [
    librewolf
    git
    kitty
    distrobox
  ];
}
