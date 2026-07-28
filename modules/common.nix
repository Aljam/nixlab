{ config, pkgs, ... }:

{
  # Allow unfree packages fleet-wide
  nixpkgs.config.allowUnfree = true;

  # Set global timezone and locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable Flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Essential system packages across desktop/laptop systems
  environment.systemPackages = with pkgs; [
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
  networking.networkmanager.enable = true;
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
  };

  users.users.aljam = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... aljam@navi" # Put your actual public key here!
    ];
  };


}
