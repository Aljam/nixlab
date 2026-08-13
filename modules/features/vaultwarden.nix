{ config, pkgs, domains, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "127.0.0.1";
      SIGNUPS_ALLOWED = false; # SET TO FALSE AFTER ACCOUNT CREATION
      DOMAIN = "https://vault.${domains.primary}";
    };
  };
}
