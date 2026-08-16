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
    "https://nix-community.cachix.org"
    "https://nix-gaming.cachix.org"
    "https://hyprland.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:zwP87Cg278Hv3zqJl7mV3KqPqPqPqPqPqPqPqPqPqPq="
    "nix-gaming.cachix.org-1:Q0m0+7k8+Gv3Z8h0+8v3Z8h0+8v3Z8h0+8v3Z8h0+8v="
    "hyprland.cachix.org-1:Q0m0+7k8+Gv3Z8h0+8v3Z8h0+8v3Z8h0+8v3Z8h0+8v="
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
