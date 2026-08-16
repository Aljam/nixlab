# modules/roles/common.nix
# Common configuration for all NixOS hosts
{ config, lib, pkgs, ... }:
{
  config = {
    # Environment
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

    # Networking
    networking.hostName = config.networking.fleet.hostname or "nixos";
    networking.domain = config.networking.fleet.domains.primary or "local";

    # Nix settings
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        trusted-users = [ "root" "@wheel" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    # Services
    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          AllowUsers = [ "aljam" ];
        };
      };
    };

    # Sops
    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.secrets = {};

    # Users
    users.users.aljam = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
}
