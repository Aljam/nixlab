{ config, pkgs, lib, ... }:

{
  # Allow unfree packages fleet-wide
  nixpkgs.config.allowUnfree = true;

  # Fleet-wide default state version
  system.stateVersion = lib.mkDefault "23.11";

  # Set global timezone and locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable Flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Ensure sudo is explicitly enabled fleet-wide (usually default, but good to ensure)
  security.sudo.enable = true;
  
  # Essential system packages across desktop/laptop systems
  environment.systemPackages = with pkgs; [
    home-manager
    git
    htop
    wget
    curl
    yt-dlp
    ffmpeg
    vim
    cifs-utils
    kitty.terminfo # Fixes SSH terminal issues when connecting from Kitty
    lm_sensors
    iotop
    nvd
    nix-tree
    iperf3
    nmap
    tcpdump
    duf
  ];

  # Networking baseline
  services.tailscale.enable = true;

  # Bluetooth baseline
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable SSH fleet-wide
  services.openssh = {
    enable = true;
    # Require keys instead of passwords (highly recommended)
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Automatically optimize the Nix store (deduplicates identical files)
  nix.optimise.automatic = true;

}
