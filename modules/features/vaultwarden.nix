{ config, pkgs, domains, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "0.0.0.0";
      SIGNUPS_ALLOWED = false; # SET TO FALSE AFTER ACCOUNT CREATION
      DOMAIN = "https://vault.${domains.primary}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8222 ]; # Vaultwarden
}
