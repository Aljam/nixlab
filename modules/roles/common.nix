# modules/roles/common.nix
# Common configuration for all NixOS machines
# Applied to: all hosts
{
  config,
  lib,
  pkgs,
  ...  # fleet, subnets, domains wired via specialArgs
}:

{
  imports = [
    ../features/boot.nix
  ];

  # Timezone and locale
  time.timeZone = lib.mkDefault "America/Toronto";
  i18n.defaultLocale = lib.mkDefault "en_CA.UTF-8";

  # User configuration
  users.mutableUsers = false;

  # Sudo configuration
  security.sudo = {
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };

  # sops configuration
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    maxRetry = 5;
    findTime = "10min";
    banTime = "30min";
  };

  # Cachix substituters
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:MZdHKglynCuK+xf+JtDiX6aIT1yFX8Jv18LwqT4KKs4="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZFYNs5vDq1Wx0="
    ];
  };

  # System packages
  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.curl
    pkgs.wget
    pkgs.jq
  ];
}
