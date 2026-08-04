{ config, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "0.0.0.0";

      SIGNUPS_ALLOWED = true; # SET TO FALSE AFTER ACCOUNT CREATION

      DOMAIN = "https://vault.derezzed.info";
    };
  };
}
