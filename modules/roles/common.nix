{ config, pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.sudo.enable = true;

  networking.networkmanager.enable = true;

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
    kitty.terminfo # Fixes missing terminfo when connecting via SSH from Kitty
    lm_sensors
    iotop
    nvd
    nix-tree
    iperf3
    nmap
    tcpdump
    duf
    sops
  ];

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  nix.optimise.automatic = true;
}
