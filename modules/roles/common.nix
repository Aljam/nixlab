# modules/roles/common.nix
# Common configuration for all NixOS machines
# Applied to: all hosts
{
  config,
  lib,
  pkgs,
  hostname,
  domains,
  subnets,
  fleet,
  ...  # specialArgs wired from flake.nix
}:

{
  imports = [
    ../features/boot.nix
  ];

  # Fleet wiring - required by server-core, grafana, vaultwarden, reverse-proxy-backends
  networking.fleet = fleet;
  networking.subnets = subnets;
  networking.domain = domains.primary;
  networking.hostName = hostname;

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
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "aljam" ];
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
      "https://aljam.cachix.org"
      "https://hyprland.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:MZdHKglynCuK+xf+JtDiX6aIT1yFX8Jv18LwqT4KKs4="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZFYNs5vDq1Wx0="
      "aljam.cachix.org-1:Q0m0+7k8+Gv3Z8h0+8v3Z8h0+8v3Z8h0+8v3Z8h0+8v="
      "hyprland.cachix.org-1:a7pgxzMz7+chdWEdtP1Bm+9pqVh+Ve5tA5Rb4S0R7aY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = [
    pkgs.git
    pkgs.vim
    pkgs.curl
    pkgs.wget
    pkgs.jq
  ];
}
