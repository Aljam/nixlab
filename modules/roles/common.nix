{ hostname, config, pkgs, lib, ... }:

{
  imports = [
    ../features/boot.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = hostname;
  system.stateVersion = "26.05";

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org" # see §32
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };


  security.sudo.enable = true;
  users.mutableUsers = false;
  services.fail2ban.enable = true;
  security.sudo.execWheelOnly = true;
  boot.tmp.cleanOnBoot = true;
  

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
  ];

  services.openssh = {
    enable = true;
    settings.AllowUsers = [ "aljam" ];
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
