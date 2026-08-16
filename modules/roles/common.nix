# modules/roles/common.nix
# Common configuration for all machines
{ config, lib, pkgs, hostname, fleet, domains, subnets, ... }:
{
  # Global options
  options.servicesHostIP = lib.mkOption {
    type = lib.types.str;
    default = "127.0.0.1";
    description = "IP address that backend services bind to for HAProxy access";
  };

  imports = [
    ../hardware/cpu.nix
    ../hardware/network.nix
  ];

  # Fleet wiring
  networking.fleet = fleet.${hostname};
  networking.subnets = subnets;
  networking.domain = domains.${hostname};
  networking.hostName = hostname;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set up cachix caches (keep your existing keys)
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://aljam.cachix.org"
    "https://nix-community.cachix.org"
    "https://nix-gaming.cachix.org"
    "https://hyprland.cachix.org"
    "https://cuda-maintainers.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "aljam.cachix.org-1:Q0m0+7k8+Gv3Z8h0+8v3Z8h0+8v3Z8h0+8v3Z8h0+8v="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];

  # SOPS for secrets
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      UsePAM = false;
      AllowUsers = null;  # Managed by fail2ban
      AllowGroups = [ "wheel" ];
    };
    # Only allow key-based auth for wheel
    extraConfig = ''
      Match Group wheel
        AuthenticationMethods publickey
    '';
  };

  # Fail2ban for SSH
  services.fail2ban = {
    enable = true;
    maxRetry = 3;
    findTime = 600;
    banTime = 3600;
    extraConfig = ''
      [sshd]
      enabled = true
      port = ssh
      logpath = %(sshd_log)s
      backend = %(sshd_backend)s
    '';
  };

  # Users
  users.mutableUsers = false;

  # Common packages
  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.curl
    pkgs.wget
    pkgs.jq
    pkgs.ripgrep
    pkgs.fd
    pkgs.htop
    pkgs.btop
  ];
}
