{ hostname, config, pkgs, lib, ... }:

{
  imports = [
    ../features/boot.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = hostname;
  system.stateVersion = "26.05"

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.sudo.enable = true;
  users.mutableUsers = false
  services.fail2ban.enable = true
  security.sudo.execWheelOnly = true
  boot.tmp.cleanOnBoot = true
  

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
    duf
    sops
  ];

  services.openssh = {
    enable = true;
    settings.AllowUsers = [ "aljam" ]
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;
}
