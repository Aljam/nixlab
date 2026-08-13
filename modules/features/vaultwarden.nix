{ config, pkgs, domains, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "${subnets.lan}.2";
      SIGNUPS_ALLOWED = false; # SET TO FALSE AFTER ACCOUNT CREATION
      DOMAIN = "https://vault.${domains.primary}";
    };
  };
}
