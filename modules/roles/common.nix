# modules/roles/common.nix
# Common configuration for all hosts
{ config, lib, pkgs, hostname, domains, subnets, fleet, ... }:

{
  # Wire fleet/subnets from specialArgs into config.networking.*
  # so service modules can use config.networking.fleet.proxy.ip etc.
  networking.fleet = fleet;
  networking.subnets = subnets;
  networking.domain = domains.primary;

  # Basic system settings
  system.stateVersion = "26.05";

  # Enable networking
  networking.hostName = hostname;

  # Set your time zone
  time.timeZone = "America/Toronto";

  # Select internationalisation properties
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure console keymap
  console.keyMap = "us";

  # Nix settings
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Disable sudo timeout
  security.sudo.wheelNeedsPassword = true;

  # Users should not be mutable
  users.mutableUsers = false;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
    tree
    eza
    btop
    fastfetch
    zip
    unzip
    p7zip
    lsof
    socat
    jq
    yq
    fd
    ripgrep
    fzf
    tealdeer
    bat
    zoxide
    direnv
    nix-index
    nix-output-monitor
    nixfmt-classic
    nil
  ];

  # Some programs need SUID wrappers
  security.wrappers = {
    bwrap = {
      source = "${pkgs.bubblewrap}/bin/bwrap";
      owner = "root";
      group = "root";
      permissions = "u+rwx,g=rx,o=rx";
      setuid = true;
    };
  };

  # Boot settings
  boot.loader.timeout = 5;

  # Documentation
  documentation = {
    enable = true;
    doc.enable = false;
    info.enable = false;
    man.enable = true;
  };

  # SOPS for secrets
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # SSH configuration - hardened
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "aljam" ];
    };
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    maxRetry = 5;
    findTime = "10min";
    banTime = "1h";
  };

  # ZSH
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
}
