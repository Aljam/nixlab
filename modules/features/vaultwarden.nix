{ config, pkgs, domains, fleet, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "${fleet.r730xd.ip}";
      SIGNUPS_ALLOWED = false; # SET TO FALSE AFTER ACCOUNT CREATION
      DOMAIN = "https://vault.${domains.primary}";
    };
  };
}
