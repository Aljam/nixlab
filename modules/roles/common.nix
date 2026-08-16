# modules/roles/common.nix
# Common configuration for all machines
{ config, lib, pkgs, ... }:
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

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set up cachix caches
  nix.settings.substituters = [
    "https://aljam.cachix.org"
    "https://nix-community.cachix.org"
    "https://nix-gaming.cachix.org"
    "https://hyprland.cachix.org"
    "https://cuda-maintainers.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "aljam.cachix.org-1:E3E80fk8YEaTw0Y9V+0IHmhrvLQ/xACZ1VMXDZZ80oo="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];

  # SOPS for secrets
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      UsePAM = false;
    };
  };

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

  # Fleet configuration
  # This is where per-host settings from flake.nix are applied
  # fleet.<hostname>.ip is set in flake.nix specialArgs
}
