{ config, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/vaultwarden/backup";
    config = {
      ROCKET_PORT = 8222;
      ROCKET_ADDRESS = "127.0.0.1";

      SIGNUPS_ALLOWED = true; # SET TO FALSE AFTER ACCOUNT CREATION

      DOMAIN = "https://vault.derezzed.info";
    };
  };
}
